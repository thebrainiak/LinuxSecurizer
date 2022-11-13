#!/bin/bash


#PROTEGIENDO EL GRUB
grubprotect() {

      read -p "Deseas proteger el GRUB?: (S or N) " a

      if [ $a == S ]
      then
            echo -e "\n Introduce la contraseña para encriptarla\n"
            grub-mkpasswd-pbkdf2
            read -r -p "Copia aqui contraseña encriptada desde grub.pbkdf2.sha512 hasta el final  :" passgrub
            read -r -p "Nombre de usuario para el Grub: "  usergrub
            #Añadimos la protección en 00_header
echo "cat << EOF
set superusers="$usergrub"
password-pbkdf2 $usergrub $passgrub
EOF" >> /etc/grub.d/00_header

#Añadimos la protección en el bootloader
echo "set superusers="$usergrub"
password-pbkdf2 $usergrub $passgrub" >> /etc/grub.d/40_custom


             #Actualizamos grub
             update-grub2

             echo -e "\n Tu GRUB ahora está protegido con usuario y contraseña. \n "

       else

             echo -e "\n No se ha protegido el GRUB. \n "
       fi
}

friendreco() {

      read -p "¿Quieres eliminar el Friendly Recovery?:  (S or N): " b

      if [ $b == S ]

      then

            #Desinstalando friendly recovery para complicar las cosas en el bootloader
            apt purge friendly-recovery
            update-grub

            echo -e "\n Se ha desinstalado Friendly Recovery. \n "

      else

            echo -e "\n No se ha desinstalado Friendly Recovery. \n "

      fi
}

instaselinux() {

       read -p "¿Quieres sutituir Apparmor por SELinux? (S or N): " c

       if [ $c == S ]

       then
            #Detener Apparmor para sustituirlo por SELinux
            systemctl stop apparmor
            systemctl disable apparmor

            #Instalando SELinux
            apt install policycoreutils selinux-basics selinux-utils -y

            #Activando SELinux
            selinux-activate
            #Cambiando modo de SELinux
            perl -pi -e 's/permissive/enforcing/g' /etc/selinux/config

            echo -e "\n AppArmor ha sido deshabilitado y se ha activado la protección de SELinux en modo Enforcing. \n "

       else

            echo -e "\n No se ha instalado SELinux. \n "

       fi
}

cortafuegos() {

        read -p "¿Quieres instalar el entorno gráfico del cortafuegos? (S or N): " d

        if [ $d == S ]

        then
             #Instalando entorno grafico del cortafuegos
             apt-get install gufw
             #Activando el cortafuegos
             ufw enable

             echo -e "\n Entorno gráfico del cortafuegos instalado. \n "

        else

           echo -e "\n No se ha instalado la GUI del cortafuegos. \n "

        fi
}

instaclamav() {

       read -p "¿Quieres instalar CalmAv como antimalware? (S or N): " e

       if [ $e == S ]

       then

           #Instalando ClamAV

           wget https://www.clamav.net/downloads/production/clamav-0.105.1-2.linux.x86_64.deb

           dpkg -i clam*

           rm clam*

           apt upgrade clamav

           perl -pi -e 's/DatabaseOwner clamav/#DatabaseOwner clamav/g' /usr/local/etc/freshclam.conf
           
           echo "DatabaseOwner $USER" >> /usr/local/etc/freshclam.conf
           #Activando archivo de configuración
           mv /usr/local/etc/freshclam.conf.sample /usr/local/etc/freshclam.conf
           perl -pi -e 's/Example/#Example/g' /usr/local/etc/freshclam.conf
           #Actualizando Base de Datos
           freshclam

           #Instalando interfaz grafica
           apt install clamtk

          #Activando el servicio de Clamav
           systemctl start clamav-freshclam

           #Añadimos al Cron la regla de que se realice un análisis de todo el sistema cada día

           echo -e "\n Se ha instalado y configurado ClamAV como antimalware \n "

        else

           echo -e "\n No se ha instalado ClamAV. \n "

        fi
}

instarkhunter() {

        read -p "¿Quieres instalar RKHunter para buscar rootkits? (S or N): " f

        if [ $f == S ]

        then
             #Instalando RKHunter para buscar rootkits
             apt install rkhunter

             perl -pi -e 's/UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/g' /etc/rkhunter.conf
             perl -pi -e 's/MIRRORS_MODE=1/MIRRORS_MODE=0/g' /etc/rkhunter.conf
             perl -pi -e 's/WEB_CMD/#WEB_CMD/g' /etc/rkhunter.conf
             echo "WEB_CMD=""" >> /etc/rkhunter.conf

             #Lo configuramos para que se realice un análisis de forma diaria
             perl -pi -e 's/CRON_DAILY_RUN=""/CRON_DAILY_RUN="true"/g' /etc/default/rkhunter
             perl -pi -e 's/CRON_DB_UPDATE=""/CRON_DB_UPDATE="true"/g' /etc/default/rkhunter
             perl -pi -e 's/APT_AUTOGEN="false"/APT_AUTOGEN="true"/g' /etc/default/rkhunter

             #Actualizamos rkhunter

             rkhunter --update

             echo -e "\n Se ha instalado y configurado RKHUnter para buscar rootkits. \n "

         else

             echo -e "\n No se ha instalado RKHunter. \n "
         fi

}

instachkrootkit() {

       read -p "¿Quieres instalar chkrootkit? (S or N): " g

       if [ $g == S ]

       then
            #Instalando chkrootkit

            apt install chkrootkit

            #Analisis de archivos

            chkrootkit

            echo -e "\n Se ha instalado y configurado chkrootkit para buscar rootkits y malware. \n "
       else

            echo -e "\n No se ha instalado chkrootkit. \n "

       fi
}

puertoimpresion() {

       read -p "¿Deseas desactivar el puerto 631 para imprimir? (S or N): " h

       if [ $h == S ]

       then
            #Desactivando servicio de impresion que deja el puerto 631 abierto.
            ufw deny 631
            echo -e "\n Se ha desactivado el puerto de impresión. \n "
       else
            echo -e "\n No se ha desactivado el puerto de impresión.  \n "

       fi
}

kernelproteccion() {

       read -p "¿Deseas proteger el Kernel? (S or N): " i

       if [ $i == S ]

       then

#PROTEGIENDO EL KERNEL

echo "kernel.exec-shield=1
kernel.randomize_va_space=1
# Enable IP spoofing protection
net.ipv4.conf.all.rp_filter=1
# Disable IP source routing
net.ipv4.conf.all.accept_source_route=0
# Ignoring broadcasts request
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_messages=1
# Make sure spoofed packets get logged
net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf

             echo -e "\n Se ha protegido el kernel. \n "

        else

             echo -e "\n No se ha protegido el Kernel. \n "
        fi
}

ipv6desactivacion() {
        read -p "¿Deseas desactivar IPV6? (S or N): " j

        if [ $j == S ]

        then

             #Desactivando IPV6

             sysctl -w net.ipv6.conf.all.disable_ipv6=1
             sysctl -w net.ipv6.conf.default.disable_ipv6=1

             echo -e "\n Se ha desactivado IPV6 para mayor seguridad. \n "
        else

             echo -e "\n No se ha desactivado IPV6. \n"
        fi
}

sdintrusos() {

        read -p "¿Deseas instalar un sistema de detección de intrusos? (S or N): " k

        if [ $k == S ]

        then

             #Instalando AIDE Sistema de Deteccion de intrusos

             apt install aide


             read -p "¿A qué e-mail quieres que AIDE envíe la actividad sospechosa?: " emailaide

             perl -pi -e 's/MAILTO/#MAILTO/g' /etc/default/aide
             
             echo "MAILTO="$emailaide"" >> /etc/default/aide

             #Generando database de AIDE

             echo -e "\n Generando database de AIDE \n "

             aideinit &

             time_out=10


             echo -e "\n Se ha instalado un sistema de detección de intrusos. \n "

        else

             echo -e "\n No se ha instalado un sistema de detección de intrusos \n "
        fi
}

monitoreo() {

        read -p "¿Deseas instalar lnav para monitorear los logs? (S or N): " l

        if [ $l == S ]

        then

              #Instalando LNAV para monitorear los logs

              apt-get install lnav
              echo -e "\n Se ha instalado LNAV para monitorear logs. \n "

        else

              echo -e "\n No se ha instalado LNAV. \n "
        fi
}

despedida() {

              echo -e "\n \Enhorabuena, tu linux ahora está securizado. \n "
              echo -e "\n \e[31m AVISO: Esto no garantiza nada pero complica las cosas a un atacante. \e[31m \n "

              echo -e "\n \e[1m \e[34m [*] ES NECESARIO REINICIAR EL PC PARA APLICAR LOS CAMBIOS \e[34m \e[1m \n "
}

    read -p "¿Estas listo para comenzar?: ( S or N )  " m
    if [ $m == S ]

    then

         grubprotect

         friendreco

         instaselinux

         cortafuegos

         instaclamav

         instarkhunter

         instachkrootkit

         puertoimpresion

         kernelproteccion

         ipv6desactivacion

         sdintrusos

         monitoreo

         despedida

    else

         echo -e "\n \e[31m La securización ha sido cancelada. \e[31m \n "
    fi


