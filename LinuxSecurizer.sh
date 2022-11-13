#!/bin/bash


#PROTEGIENDO EL GRUB
grubprotect() {

      read -p "Deseas proteger el GRUB?: (S or N) " listo1

      if [ $listo1 == S ]
      then
            echo -e "\n \e[43mIntroduce la contraseña para encriptarla\e[43m \n"
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

             echo -e "\n \e[32m Tu GRUB ahora está protegido con usuario y contraseña. \e[32m \n "

       else

             echo -e "\n \e[31m Como te hagan una redada te vas a acordar de esta opción. \e[31m \n "
       fi
}

friendreco() {

      read -p "¿Quieres eliminar el Friendly Recovery?:  (S or N): " listo2

      if [ $listo2 == S ]

      then

            #Desinstalando friendly recovery para complicar las cosas en el bootloader
            apt purge friendly-recovery
            update-grub

            echo -e "\n \e[32m Se ha desinstalado Friendly Recovery. \e[32m \n "

      else

            echo -e "\n \e[31m No se ha desinstalado Friendly Recovery. \e[31m \n "

      fi
}

instaselinux() {

       read -p "¿Quieres sutituir Apparmor por SELinux? (S or N): " listo3

       if [ $listo3 == S ]

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

            echo -e "\n \e[32m AppArmor ha sido deshabilitado y se ha activado la protección de SELinux en modo Enforcing. \e[32m \n "

       else

            echo -e "\n \e[31m No se ha instalado SELinux. \e[31m \n "

       fi
}

cortafuegos() {

        read -p "¿Quieres instalar el entorno gráfico del cortafuegos? (S or N): " listo4

        if [ $listo4 == S ]

        then
             #Instalando entorno grafico del cortafuegos
             apt-get install gufw
             #Activando el cortafuegos
             ufw enable

             echo -e "\n \e[32m Entorno gráfico del cortafuegos instalado. \e[32m \n "

        else

           echo -e "\n \e[31m No se ha instalado la GUI del cortafuegos. \e[31m \n "

        fi
}

instaclamav() {

       read -p "¿Quieres instalar CalmAv como antimalware? (S or N): " listo5

       if [ $listo5 == S ]

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

           echo -e "\n \e[32m Se ha instalado y configurado ClamAV como antimalware \e[32m \n "

        else

           echo -e "\n \e[31m No se ha instalado ClamAV. \e[31m \n "

        fi
}

instarkhunter() {

        read -p "¿Quieres instalar RKHunter para buscar rootkits? (S or N): " listo6

        if [ $listo6 == S ]

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

             echo -e "\n \e[32m Se ha instalado y configurado RKHUnter para buscar rootkits. \e[32m \n "

         else

             echo -e "\n \e[31m No se ha instalado RKHunter. \e[31m \n "
         fi

}

instachkrootkit() {

       read -p "¿Quieres instalar chkrootkit? (S or N): " listo7

       if [ $listo7 == S ]

       then
            #Instalando chkrootkit

            apt install chkrootkit

            #Analisis de archivos

            chkrootkit

            echo -e "\n \e[32m Se ha instalado y configurado chkrootkit para buscar rootkits y malware. \e[32m \n "
       else

            echo -e "\n \e[31m No se ha instalado chkrootkit. \e[31m \n "

       fi
}

puertoimpresion() {

       read -p "¿Deseas desactivar el puerto 631 para imprimir? (S or N): " listo8

       if [ $listo8 == S ]

       then
            #Desactivando servicio de impresion que deja el puerto 631 abierto.
            ufw deny 631
            echo -e "\n \e[32m Se ha desactivado el puerto de impresión. \e[32m \n "
       else
            echo -e "\n \e[31m No se ha desactivado el puerto de impresión \e[31m \n "

       fi
}

kernelproteccion() {

       read -p "¿Deseas proteger el Kernel? (S or N): " listo9

       if [ $listo9 == S ]

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

             echo -e "\n \e[32m Se ha protegido el kernel. \e[32m \n "

        else

             echo -e "\n \e[31m No se ha protegido el Kernel \e[31m \n "
        fi
}

ipv6desactivacion() {
        read -p "¿Deseas desactivar IPV6? (S or N): " listo10

        if [ $listo10 == S ]

        then

             #Desactivando IPV6

             sysctl -w net.ipv6.conf.all.disable_ipv6=1
             sysctl -w net.ipv6.conf.default.disable_ipv6=1

             echo -e "\n \e[32m Se ha desactivado IPV6 para mayor seguridad \e[32m \n "
        else

             echo -e "\n \e[31m No se ha desactivado IPV6 \e[31m \n"
        fi
}

sdintrusos() {

        read -p "¿Deseas instalar un sistema de detección de intrusos? (S or N): " listo11

        if [ $listo11 == S ]

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


             echo -e "\n \e[32m Se ha instalado un sistema de detección de intrusos. \e[32m \n "

        else

             echo -e "\n \e[31m No se ha instalado un sistema de detección de intrusos \e[31m \n "
        fi
}

monitoreo() {

        read -p "¿Deseas instalar lnav para monitorear los logs? (S or N): " listo12

        if [ $listo12 == S ]

        then

              #Instalando LNAV para monitorear los logs

              apt-get install lnav
              echo -e "\n \e[32m Se ha instalado LNAV para monitorear logs. \e[32m \n "

        else

              echo -e "\n \e[31m No se ha instalado LNAV. \e[31m \n "
        fi
}

despedida() {

              echo -e "\n \e[32m Enhorabuena, tu linux ahora está securizado. \e[32m \n "
              echo -e "\n \e[31m AVISO: Esto no garantiza nada pero complica las cosas a un atacante. \e[31m \n "

              echo -e "\n \e[1m \e[34m [*] ES NECESARIO REINICIAR EL PC PARA APLICAR LOS CAMBIOS \e[34m \e[1m \n "
}

    read -p "¿Estas listo para comenzar?: ( S or N )  " listo
    if [ $listo == S ]

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


