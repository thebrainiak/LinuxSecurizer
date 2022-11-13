# LinuxSecurizer
Script que realiza cambios básicos en sistemas operativos linux para darle una capa más de seguridad.
Funcionamiento:

Dar permisos de root con sudo chmod +x [script] y ejecutar.

¿Qué corrige este script?

-Añade usuario y contraseña encriptada al Grub.

-Elimina Friendly Recovery.

-Cambia AppArmos por SELinux y lo activa en modo enforcing.

-Instala la interfaz gráfica del cortafuegos UFW.

-Instala ClamAV como antimalware.

-Instala RKHunter para detectar rootkits.

-Instala CHKRootkit como segundo antimalware y detector de rootkits.

-Bloquea el puerto de impresión que se suelen dejar abierto algunos linux.

-Securiza el Kernel y activa otras funciones como la detecciñon de IP Spoofing, deshabilita el IP Routing, ignora las peticiones de Broadcast y se asegura de que los paquetes falsificados se registren.

-Desactiva IPV6 para evitar otros tipos de ataque.

-Instala AID como sistema de deteccón de intrusos y envía informes al correo especificado.

-Instala LNAV, una herramienta que facilita el monitoreo de logs.
