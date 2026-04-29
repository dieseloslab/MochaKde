# /etc/nixos/modules/mocha-app-picker.nix
#
# Diesel OS Lab - GNOME Mocha Edition
#
# Mocha App Picker
#
# Aplicativo gráfico em Rust para seleção de aplicativos opcionais.
#
# Arquitetura atual:
#   - backend Nix:
#       gera /etc/nixos/modules/optional-apps.nix
#       executa nixos-rebuild switch quando houver mudança declarativa
#
#   - backend Flatpak:
#       instala aplicativos via Flathub global/system
#       não executa nixos-rebuild quando só houver Flatpak
#
#   - backend Special:
#       reservado para casos com tratamento próprio
#       atualmente cobre pacotes declarativos com serviço opcional
#       como TeamViewer e AnyDesk
#
# Firefox permanece como navegador padrão.
# Brave, Vivaldi, ProtonPlus, Heroic, RustDesk, TeamViewer, AnyDesk etc.
# são opcionais.

{ pkgs, ... }:

let
  mochaAppPickerSrc = pkgs.writeText "mocha-app-picker.rs" ''
    use std::collections::BTreeSet;
    use std::env;
    use std::fs;
    use std::path::Path;
    use std::process::Command;
    use std::thread;
    use std::time::Duration;

    const OPTIONAL_APPS_PATH: &str = "/etc/nixos/modules/optional-apps.nix";

    const ZENITY: &str = "${pkgs.zenity}/bin/zenity";
    const BASH: &str = "${pkgs.bash}/bin/bash";
    const INSTALL: &str = "${pkgs.coreutils}/bin/install";
    const DIRNAME: &str = "${pkgs.coreutils}/bin/dirname";
    const MV: &str = "${pkgs.coreutils}/bin/mv";
    const CMP: &str = "${pkgs.diffutils}/bin/cmp";
    const GREP: &str = "${pkgs.gnugrep}/bin/grep";
    const FLATPAK: &str = "${pkgs.flatpak}/bin/flatpak";
    const NIXOS_REBUILD: &str = "/run/current-system/sw/bin/nixos-rebuild";
    const PKEXEC: &str = "/run/wrappers/bin/pkexec";

    #[derive(Copy, Clone)]
    enum Lang {
        PtBr,
        EnUs,
        EsEs,
        FrFr,
    }

    fn lang_from_value(value: &str) -> Option<Lang> {
        let normalized = value
            .trim()
            .replace('-', "_")
            .to_ascii_lowercase();

        if normalized.starts_with("pt_br") || normalized == "pt" || normalized.starts_with("pt_") {
            return Some(Lang::PtBr);
        }

        if normalized.starts_with("en_us") || normalized == "en" || normalized.starts_with("en_") {
            return Some(Lang::EnUs);
        }

        if normalized.starts_with("es_es") || normalized == "es" || normalized.starts_with("es_") {
            return Some(Lang::EsEs);
        }

        if normalized.starts_with("fr_fr") || normalized == "fr" || normalized.starts_with("fr_") {
            return Some(Lang::FrFr);
        }

        None
    }

    fn detect_lang() -> Lang {
        for key in ["MOCHA_LANG", "LC_ALL", "LC_MESSAGES", "LANG"] {
            if let Ok(value) = env::var(key) {
                if let Some(lang) = lang_from_value(&value) {
                    return lang;
                }
            }
        }

        Lang::EnUs
    }

    fn tr(lang: Lang, key: &'static str) -> &'static str {
        match lang {
            Lang::PtBr => match key {
                "title" => "Mocha App Picker",
                "choose.text" => "Selecione os aplicativos opcionais que deseja instalar/manter.\n\nNix: altera optional-apps.nix e aplica rebuild.\nFlatpak: instala via Flathub system sem rebuild.\nSpecial: usa tratamento especial declarativo ou handler próprio.\n\nNesta versão, desmarcar Flatpak não desinstala automaticamente.",
                "button.install" => "Instalar",
                "button.exit" => "Sair",
                "col.install" => "Instalar",
                "col.id" => "ID",
                "col.program" => "Programa",
                "col.origin" => "Origem",
                "col.category" => "Categoria",
                "col.description" => "Descrição",
                "optional.managed_comment" => "Este arquivo é gerenciado pelo Mocha App Picker.",
                "optional.chosen_comment" => "Programas opcionais escolhidos pelo usuário após a instalação.",
                "script.no_nix_changes" => "Seleção declarativa Nix sem alterações.",
                "script.skip_rebuild" => "Pulando nixos-rebuild.",
                "script.write_nix" => "Gravando seleção declarativa Nix em",
                "script.apply_rebuild" => "Aplicando mudanças declarativas com nixos-rebuild switch...",
                "script.special_selected" => "Casos especiais selecionados:",
                "script.special_info" => "Os casos especiais atuais são tratados de forma declarativa quando possuem pacote/serviço NixOS.",
                "script.ensure_flathub" => "Garantindo repositório Flathub global...",
                "script.install_flatpak_selected" => "Instalando aplicativos Flatpak selecionados...",
                "script.flatpak_already" => "Flatpak já instalado",
                "script.install_flatpak" => "Instalando Flatpak",
                "script.no_flatpak" => "Nenhum aplicativo Flatpak novo foi selecionado.",
                "script.success" => "Instalação concluída com sucesso.",
                "progress.installing" => "Instalando aplicativos selecionados...",
                "info.success" => "Instalação concluída com sucesso.",
                "error.open_gui" => "Falha ao abrir a janela gráfica",
                "error.write_file" => "Falha ao gravar",
                "error.prepare_script" => "Falha ao preparar script de instalação",
                "error.read_log" => "Não foi possível ler o log em",
                "error.install_failed" => "A instalação não foi concluída.",
                "error.auth_start" => "Falha ao iniciar autenticação/instalação",
                "error.pkexec_missing" => "Verifique se /run/wrappers/bin/pkexec existe.",
                "error.no_etc_nixos" => "Este programa espera encontrar /etc/nixos.",
                "error.prepare_optional" => "Falha ao preparar optional-apps.nix",
                "log.last_lines" => "Últimas linhas do log",
                _ => tr(Lang::EnUs, key),
            },
            Lang::EnUs => match key {
                "title" => "Mocha App Picker",
                "choose.text" => "Select the optional applications you want to install/keep.\n\nNix: changes optional-apps.nix and applies a rebuild.\nFlatpak: installs from the system Flathub remote without a rebuild.\nSpecial: uses declarative handling or a dedicated handler.\n\nIn this version, unchecking Flatpak apps does not uninstall them automatically.",
                "button.install" => "Install",
                "button.exit" => "Exit",
                "col.install" => "Install",
                "col.id" => "ID",
                "col.program" => "Program",
                "col.origin" => "Source",
                "col.category" => "Category",
                "col.description" => "Description",
                "optional.managed_comment" => "This file is managed by Mocha App Picker.",
                "optional.chosen_comment" => "Optional programs selected by the user after installation.",
                "script.no_nix_changes" => "Declarative Nix selection unchanged.",
                "script.skip_rebuild" => "Skipping nixos-rebuild.",
                "script.write_nix" => "Writing declarative Nix selection to",
                "script.apply_rebuild" => "Applying declarative changes with nixos-rebuild switch...",
                "script.special_selected" => "Selected special cases:",
                "script.special_info" => "Current special cases are handled declaratively when they provide a NixOS package/service.",
                "script.ensure_flathub" => "Ensuring global Flathub repository...",
                "script.install_flatpak_selected" => "Installing selected Flatpak applications...",
                "script.flatpak_already" => "Flatpak already installed",
                "script.install_flatpak" => "Installing Flatpak",
                "script.no_flatpak" => "No new Flatpak application was selected.",
                "script.success" => "Installation completed successfully.",
                "progress.installing" => "Installing selected applications...",
                "info.success" => "Installation completed successfully.",
                "error.open_gui" => "Failed to open the graphical window",
                "error.write_file" => "Failed to write",
                "error.prepare_script" => "Failed to prepare the installation script",
                "error.read_log" => "Could not read the log at",
                "error.install_failed" => "The installation was not completed.",
                "error.auth_start" => "Failed to start authentication/installation",
                "error.pkexec_missing" => "Check whether /run/wrappers/bin/pkexec exists.",
                "error.no_etc_nixos" => "This program expects to find /etc/nixos.",
                "error.prepare_optional" => "Failed to prepare optional-apps.nix",
                "log.last_lines" => "Last log lines",
                _ => key,
            },
            Lang::EsEs => match key {
                "title" => "Mocha App Picker",
                "choose.text" => "Seleccione las aplicaciones opcionales que desea instalar/mantener.\n\nNix: cambia optional-apps.nix y aplica un rebuild.\nFlatpak: instala desde Flathub del sistema sin rebuild.\nSpecial: usa manejo declarativo o un handler dedicado.\n\nEn esta versión, desmarcar aplicaciones Flatpak no las desinstala automáticamente.",
                "button.install" => "Instalar",
                "button.exit" => "Salir",
                "col.install" => "Instalar",
                "col.id" => "ID",
                "col.program" => "Programa",
                "col.origin" => "Origen",
                "col.category" => "Categoría",
                "col.description" => "Descripción",
                "optional.managed_comment" => "Este archivo es gestionado por Mocha App Picker.",
                "optional.chosen_comment" => "Programas opcionales seleccionados por el usuario después de la instalación.",
                "script.no_nix_changes" => "Selección declarativa Nix sin cambios.",
                "script.skip_rebuild" => "Omitiendo nixos-rebuild.",
                "script.write_nix" => "Grabando selección declarativa Nix en",
                "script.apply_rebuild" => "Aplicando cambios declarativos con nixos-rebuild switch...",
                "script.special_selected" => "Casos especiales seleccionados:",
                "script.special_info" => "Los casos especiales actuales se tratan de forma declarativa cuando ofrecen paquete/servicio NixOS.",
                "script.ensure_flathub" => "Asegurando el repositorio global Flathub...",
                "script.install_flatpak_selected" => "Instalando aplicaciones Flatpak seleccionadas...",
                "script.flatpak_already" => "Flatpak ya instalado",
                "script.install_flatpak" => "Instalando Flatpak",
                "script.no_flatpak" => "No se seleccionó ninguna aplicación Flatpak nueva.",
                "script.success" => "Instalación completada correctamente.",
                "progress.installing" => "Instalando aplicaciones seleccionadas...",
                "info.success" => "Instalación completada correctamente.",
                "error.open_gui" => "Error al abrir la ventana gráfica",
                "error.write_file" => "Error al grabar",
                "error.prepare_script" => "Error al preparar el script de instalación",
                "error.read_log" => "No fue posible leer el log en",
                "error.install_failed" => "La instalación no se completó.",
                "error.auth_start" => "Error al iniciar autenticación/instalación",
                "error.pkexec_missing" => "Compruebe si /run/wrappers/bin/pkexec existe.",
                "error.no_etc_nixos" => "Este programa espera encontrar /etc/nixos.",
                "error.prepare_optional" => "Error al preparar optional-apps.nix",
                "log.last_lines" => "Últimas líneas del log",
                _ => tr(Lang::EnUs, key),
            },
            Lang::FrFr => match key {
                "title" => "Mocha App Picker",
                "choose.text" => "Sélectionnez les applications optionnelles à installer/conserver.\n\nNix : modifie optional-apps.nix et applique un rebuild.\nFlatpak : installe depuis le dépôt système Flathub sans rebuild.\nSpecial : utilise un traitement déclaratif ou un handler dédié.\n\nDans cette version, décocher des applications Flatpak ne les désinstalle pas automatiquement.",
                "button.install" => "Installer",
                "button.exit" => "Quitter",
                "col.install" => "Installer",
                "col.id" => "ID",
                "col.program" => "Programme",
                "col.origin" => "Source",
                "col.category" => "Catégorie",
                "col.description" => "Description",
                "optional.managed_comment" => "Ce fichier est géré par Mocha App Picker.",
                "optional.chosen_comment" => "Programmes optionnels sélectionnés par l'utilisateur après l'installation.",
                "script.no_nix_changes" => "Sélection déclarative Nix inchangée.",
                "script.skip_rebuild" => "nixos-rebuild ignoré.",
                "script.write_nix" => "Écriture de la sélection déclarative Nix dans",
                "script.apply_rebuild" => "Application des changements déclaratifs avec nixos-rebuild switch...",
                "script.special_selected" => "Cas spéciaux sélectionnés :",
                "script.special_info" => "Les cas spéciaux actuels sont traités de façon déclarative lorsqu'ils disposent d'un paquet/service NixOS.",
                "script.ensure_flathub" => "Vérification du dépôt global Flathub...",
                "script.install_flatpak_selected" => "Installation des applications Flatpak sélectionnées...",
                "script.flatpak_already" => "Flatpak déjà installé",
                "script.install_flatpak" => "Installation du Flatpak",
                "script.no_flatpak" => "Aucune nouvelle application Flatpak sélectionnée.",
                "script.success" => "Installation terminée avec succès.",
                "progress.installing" => "Installation des applications sélectionnées...",
                "info.success" => "Installation terminée avec succès.",
                "error.open_gui" => "Échec de l'ouverture de la fenêtre graphique",
                "error.write_file" => "Échec de l'écriture",
                "error.prepare_script" => "Échec de la préparation du script d'installation",
                "error.read_log" => "Impossible de lire le journal dans",
                "error.install_failed" => "L'installation n'a pas été terminée.",
                "error.auth_start" => "Échec du démarrage de l'authentification/installation",
                "error.pkexec_missing" => "Vérifiez si /run/wrappers/bin/pkexec existe.",
                "error.no_etc_nixos" => "Ce programme s'attend à trouver /etc/nixos.",
                "error.prepare_optional" => "Échec de la préparation de optional-apps.nix",
                "log.last_lines" => "Dernières lignes du journal",
                _ => tr(Lang::EnUs, key),
            },
        }
    }

    fn app_name(_lang: Lang, app: &App) -> &'static str {
        app.name
    }

    fn app_category(lang: Lang, app: &App) -> &'static str {
        match lang {
            Lang::PtBr => app.category,
            Lang::EnUs => match app.category {
                "Navegadores opcionais" => "Optional browsers",
                "Gaming / compatibilidade" => "Gaming / compatibility",
                "Gaming / launchers" => "Gaming / launchers",
                "Gaming / ferramentas" => "Gaming / tools",
                "Flatpak / manutenção" => "Flatpak / maintenance",
                "AppImage / manutenção" => "AppImage / maintenance",
                "Mídia" => "Media",
                "Comunicação" => "Communication",
                "Produtividade" => "Productivity",
                "Criação e streaming" => "Creation and streaming",
                "Acesso remoto / suporte" => "Remote access / support",
                _ => app.category,
            },
            Lang::EsEs => match app.category {
                "Navegadores opcionais" => "Navegadores opcionales",
                "Gaming / compatibilidade" => "Juegos / compatibilidad",
                "Gaming / launchers" => "Juegos / launchers",
                "Gaming / ferramentas" => "Juegos / herramientas",
                "Flatpak / manutenção" => "Flatpak / mantenimiento",
                "AppImage / manutenção" => "AppImage / mantenimiento",
                "Mídia" => "Multimedia",
                "Comunicação" => "Comunicación",
                "Produtividade" => "Productividad",
                "Criação e streaming" => "Creación y streaming",
                "Acesso remoto / suporte" => "Acceso remoto / soporte",
                _ => app.category,
            },
            Lang::FrFr => match app.category {
                "Navegadores opcionais" => "Navigateurs optionnels",
                "Gaming / compatibilidade" => "Jeux / compatibilité",
                "Gaming / launchers" => "Jeux / launchers",
                "Gaming / ferramentas" => "Jeux / outils",
                "Flatpak / manutenção" => "Flatpak / maintenance",
                "AppImage / manutenção" => "AppImage / maintenance",
                "Mídia" => "Média",
                "Comunicação" => "Communication",
                "Produtividade" => "Productivité",
                "Criação e streaming" => "Création et streaming",
                "Acesso remoto / suporte" => "Accès distant / support",
                _ => app.category,
            },
        }
    }

    fn app_description(lang: Lang, app: &App) -> &'static str {
        match lang {
            Lang::PtBr => app.description,
            Lang::EnUs => match app.id {
                "browser-brave" => "Chromium-based browser focused on privacy.",
                "browser-vivaldi" => "Advanced browser for power users.",
                "browser-chromium" => "Chromium-based compatibility browser.",
                "browser-librewolf" => "Privacy-hardened Firefox browser.",
                "gaming-protonplus" => "Modern manager for Proton-GE, Wine-GE, DXVK and compatibility tools.",
                "gaming-protonupqt" => "Classic manager for Proton-GE and Wine-GE.",
                "gaming-heroic" => "Launcher for Epic Games, GOG and Amazon Games.",
                "gaming-lutris" => "Game launcher and organizer for Wine, emulators and installers.",
                "gaming-bottles" => "Wine environment manager for Windows games and applications.",
                "gaming-gamescope" => "Valve micro-compositor. Useful for some games, but should not be forced by default.",
                "gaming-goverlay" => "Graphical interface for configuring MangoHud.",
                "gaming-vkbasalt" => "Vulkan post-processing for sharpening and visual effects.",
                "flatpak-warehouse" => "Graphical interface for managing Flatpaks.",
                "flatpak-flatseal" => "Graphical permission manager for Flatpak applications.",
                "appimage-gearlever" => "AppImage manager with system menu integration.",
                "media-vlc" => "Multimedia player.",
                "communication-discord" => "Discord client via Flatpak.",
                "communication-telegram" => "Telegram client via Flatpak.",
                "productivity-libreoffice" => "Free office suite.",
                "productivity-thunderbird" => "Email client.",
                "productivity-evolution-flatpak" => "Email, calendar and contacts client via Flatpak.",
                "creation-obs-flatpak" => "Recording and livestreaming via Flatpak.",
                "creation-kdenlive" => "Video editor.",
                "creation-blender" => "3D creation, modeling and rendering.",
                "creation-gimp" => "Image editor.",
                "creation-inkscape" => "Vector illustration.",
                "system-virt-manager" => "Virtual machine manager.",
                "system-gparted" => "Graphical partition editor.",
                "remote-rustdesk" => "Open-source remote access. First recommended option for support.",
                "remote-teamviewer" => "Proprietary remote access with systemd service when available on NixOS.",
                "remote-anydesk" => "Proprietary remote access with systemd service when available on NixOS.",
                _ => app.description,
            },
            Lang::EsEs => match app.id {
                "browser-brave" => "Navegador basado en Chromium enfocado en privacidad.",
                "browser-vivaldi" => "Navegador avanzado para power users.",
                "browser-chromium" => "Navegador de compatibilidad basado en Chromium.",
                "browser-librewolf" => "Navegador Firefox reforzado para privacidad.",
                "gaming-protonplus" => "Gestor moderno de Proton-GE, Wine-GE, DXVK y herramientas de compatibilidad.",
                "gaming-protonupqt" => "Gestor clásico de Proton-GE y Wine-GE.",
                "gaming-heroic" => "Launcher para Epic Games, GOG y Amazon Games.",
                "gaming-lutris" => "Launcher y organizador de juegos con Wine, emuladores e instaladores.",
                "gaming-bottles" => "Gestor de entornos Wine para juegos y programas de Windows.",
                "gaming-gamescope" => "Microcompositor de Valve. Útil en algunos juegos, pero no debe forzarse por defecto.",
                "gaming-goverlay" => "Interfaz gráfica para configurar MangoHud.",
                "gaming-vkbasalt" => "Postprocesado Vulkan para sharpening y efectos visuales.",
                "flatpak-warehouse" => "Interfaz gráfica para gestionar Flatpaks.",
                "flatpak-flatseal" => "Gestor gráfico de permisos para aplicaciones Flatpak.",
                "appimage-gearlever" => "Gestor de AppImages con integración al menú del sistema.",
                "media-vlc" => "Reproductor multimedia.",
                "communication-discord" => "Cliente Discord vía Flatpak.",
                "communication-telegram" => "Cliente Telegram vía Flatpak.",
                "productivity-libreoffice" => "Suite ofimática libre.",
                "productivity-thunderbird" => "Cliente de correo electrónico.",
                "productivity-evolution-flatpak" => "Cliente de correo, calendario y contactos vía Flatpak.",
                "creation-obs-flatpak" => "Grabación y transmisión en vivo vía Flatpak.",
                "creation-kdenlive" => "Editor de vídeo.",
                "creation-blender" => "Creación 3D, modelado y renderizado.",
                "creation-gimp" => "Editor de imágenes.",
                "creation-inkscape" => "Ilustración vectorial.",
                "system-virt-manager" => "Gestor de máquinas virtuales.",
                "system-gparted" => "Editor gráfico de particiones.",
                "remote-rustdesk" => "Acceso remoto open source. Primera opción recomendada para soporte.",
                "remote-teamviewer" => "Acceso remoto propietario con servicio systemd cuando esté disponible en NixOS.",
                "remote-anydesk" => "Acceso remoto propietario con servicio systemd cuando esté disponible en NixOS.",
                _ => app.description,
            },
            Lang::FrFr => match app.id {
                "browser-brave" => "Navigateur basé sur Chromium axé sur la confidentialité.",
                "browser-vivaldi" => "Navigateur avancé pour power users.",
                "browser-chromium" => "Navigateur de compatibilité basé sur Chromium.",
                "browser-librewolf" => "Navigateur Firefox renforcé pour la confidentialité.",
                "gaming-protonplus" => "Gestionnaire moderne pour Proton-GE, Wine-GE, DXVK et les outils de compatibilité.",
                "gaming-protonupqt" => "Gestionnaire classique pour Proton-GE et Wine-GE.",
                "gaming-heroic" => "Launcher pour Epic Games, GOG et Amazon Games.",
                "gaming-lutris" => "Launcher et organisateur de jeux avec Wine, émulateurs et installateurs.",
                "gaming-bottles" => "Gestionnaire d'environnements Wine pour jeux et programmes Windows.",
                "gaming-gamescope" => "Micro-compositeur de Valve. Utile pour certains jeux, mais ne doit pas être forcé par défaut.",
                "gaming-goverlay" => "Interface graphique pour configurer MangoHud.",
                "gaming-vkbasalt" => "Post-traitement Vulkan pour le sharpening et les effets visuels.",
                "flatpak-warehouse" => "Interface graphique pour gérer les Flatpaks.",
                "flatpak-flatseal" => "Gestionnaire graphique des permissions des applications Flatpak.",
                "appimage-gearlever" => "Gestionnaire d'AppImages avec intégration au menu système.",
                "media-vlc" => "Lecteur multimédia.",
                "communication-discord" => "Client Discord via Flatpak.",
                "communication-telegram" => "Client Telegram via Flatpak.",
                "productivity-libreoffice" => "Suite bureautique libre.",
                "productivity-thunderbird" => "Client e-mail.",
                "productivity-evolution-flatpak" => "Client e-mail, calendrier et contacts via Flatpak.",
                "creation-obs-flatpak" => "Enregistrement et diffusion en direct via Flatpak.",
                "creation-kdenlive" => "Éditeur vidéo.",
                "creation-blender" => "Création 3D, modélisation et rendu.",
                "creation-gimp" => "Éditeur d'images.",
                "creation-inkscape" => "Illustration vectorielle.",
                "system-virt-manager" => "Gestionnaire de machines virtuelles.",
                "system-gparted" => "Éditeur graphique de partitions.",
                "remote-rustdesk" => "Accès distant open source. Première option recommandée pour le support.",
                "remote-teamviewer" => "Accès distant propriétaire avec service systemd lorsqu'il est disponible dans NixOS.",
                "remote-anydesk" => "Accès distant propriétaire avec service systemd lorsqu'il est disponible dans NixOS.",
                _ => app.description,
            },
        }
    }

    #[derive(Clone)]
    struct App {
        id: &'static str,
        category: &'static str,
        name: &'static str,
        backend: &'static str,
        description: &'static str,
        nix_package: Option<&'static str>,
        flatpak_id: Option<&'static str>,
        service: Option<&'static str>,
        special_handler: Option<&'static str>,
    }

    fn app(
        id: &'static str,
        category: &'static str,
        name: &'static str,
        backend: &'static str,
        description: &'static str,
        nix_package: Option<&'static str>,
        flatpak_id: Option<&'static str>,
        service: Option<&'static str>,
        special_handler: Option<&'static str>,
    ) -> App {
        App {
            id,
            category,
            name,
            backend,
            description,
            nix_package,
            flatpak_id,
            service,
            special_handler,
        }
    }

    fn apps() -> Vec<App> {
        vec![
            app(
                "browser-brave",
                "Navegadores opcionais",
                "Brave",
                "Nix",
                "Navegador Chromium com foco em privacidade.",
                Some("brave"),
                None,
                None,
                None,
            ),
            app(
                "browser-vivaldi",
                "Navegadores opcionais",
                "Vivaldi",
                "Nix",
                "Navegador avançado para power users.",
                Some("vivaldi"),
                None,
                None,
                None,
            ),
            app(
                "browser-chromium",
                "Navegadores opcionais",
                "Chromium",
                "Nix",
                "Compatibilidade web baseada em Chromium.",
                Some("chromium"),
                None,
                None,
                None,
            ),
            app(
                "browser-librewolf",
                "Navegadores opcionais",
                "LibreWolf",
                "Nix",
                "Firefox endurecido para privacidade.",
                Some("librewolf"),
                None,
                None,
                None,
            ),
            app(
                "gaming-protonplus",
                "Gaming / compatibilidade",
                "ProtonPlus",
                "Flatpak",
                "Gerenciador moderno de Proton-GE, Wine-GE, DXVK e ferramentas de compatibilidade.",
                None,
                Some("com.vysp3r.ProtonPlus"),
                None,
                None,
            ),
            app(
                "gaming-protonupqt",
                "Gaming / compatibilidade",
                "ProtonUp-Qt",
                "Flatpak",
                "Gerenciador clássico de Proton-GE e Wine-GE.",
                None,
                Some("net.davidotek.pupgui2"),
                None,
                None,
            ),
            app(
                "gaming-heroic",
                "Gaming / launchers",
                "Heroic Games Launcher",
                "Flatpak",
                "Launcher para Epic Games, GOG e Amazon Games.",
                None,
                Some("com.heroicgameslauncher.hgl"),
                None,
                None,
            ),
            app(
                "gaming-lutris",
                "Gaming / launchers",
                "Lutris",
                "Flatpak",
                "Launcher e organizador de jogos com Wine, emuladores e instaladores.",
                None,
                Some("net.lutris.Lutris"),
                None,
                None,
            ),
            app(
                "gaming-bottles",
                "Gaming / compatibilidade",
                "Bottles",
                "Flatpak",
                "Gerenciador de ambientes Wine para jogos e programas Windows.",
                None,
                Some("com.usebottles.bottles"),
                None,
                None,
            ),
            app(
                "gaming-gamescope",
                "Gaming / ferramentas",
                "Gamescope",
                "Nix",
                "Microcompositor da Valve. Útil em alguns jogos, mas não deve ser forçado por padrão.",
                Some("gamescope"),
                None,
                None,
                None,
            ),
            app(
                "gaming-goverlay",
                "Gaming / ferramentas",
                "GOverlay",
                "Nix",
                "Interface gráfica para configurar MangoHud.",
                Some("goverlay"),
                None,
                None,
                None,
            ),
            app(
                "gaming-vkbasalt",
                "Gaming / ferramentas",
                "vkBasalt",
                "Nix",
                "Pós-processamento Vulkan para sharpening e efeitos visuais.",
                Some("vkbasalt"),
                None,
                None,
                None,
            ),
            app(
                "flatpak-warehouse",
                "Flatpak / manutenção",
                "Warehouse",
                "Flatpak",
                "Interface gráfica para gerenciar Flatpaks.",
                None,
                Some("io.github.flattool.Warehouse"),
                None,
                None,
            ),
            app(
                "flatpak-flatseal",
                "Flatpak / manutenção",
                "Flatseal",
                "Flatpak",
                "Gerenciador gráfico de permissões dos aplicativos Flatpak.",
                None,
                Some("com.github.tchx84.Flatseal"),
                None,
                None,
            ),
            app(
                "appimage-gearlever",
                "AppImage / manutenção",
                "Gear Lever",
                "Flatpak",
                "Gerenciador de AppImages com integração ao menu do sistema.",
                None,
                Some("it.mijorus.gearlever"),
                None,
                None,
            ),
            app(
                "media-vlc",
                "Mídia",
                "VLC",
                "Nix",
                "Player multimídia.",
                Some("vlc"),
                None,
                None,
                None,
            ),
            app(
                "communication-discord",
                "Comunicação",
                "Discord",
                "Flatpak",
                "Cliente Discord via Flatpak.",
                None,
                Some("com.discordapp.Discord"),
                None,
                None,
            ),
            app(
                "communication-telegram",
                "Comunicação",
                "Telegram Desktop",
                "Flatpak",
                "Cliente Telegram via Flatpak.",
                None,
                Some("org.telegram.desktop"),
                None,
                None,
            ),
            app(
                "productivity-libreoffice",
                "Produtividade",
                "LibreOffice",
                "Nix",
                "Suíte office livre.",
                Some("libreoffice-fresh"),
                None,
                None,
                None,
            ),
            app(
                "productivity-thunderbird",
                "Produtividade",
                "Thunderbird",
                "Nix",
                "Cliente de e-mail.",
                Some("thunderbird"),
                None,
                None,
                None,
            ),
            app(
                "productivity-evolution-flatpak",
                "Produtividade",
                "Evolution",
                "Flatpak",
                "Cliente de e-mail, calendário e contatos via Flatpak.",
                None,
                Some("org.gnome.Evolution"),
                None,
                None,
            ),
            app(
                "creation-obs-flatpak",
                "Criação e streaming",
                "OBS Studio",
                "Flatpak",
                "Gravação e transmissão ao vivo via Flatpak.",
                None,
                Some("com.obsproject.Studio"),
                None,
                None,
            ),
            app(
                "creation-kdenlive",
                "Criação e streaming",
                "Kdenlive",
                "Nix",
                "Editor de vídeo.",
                Some("kdenlive"),
                None,
                None,
                None,
            ),
            app(
                "creation-blender",
                "Criação e streaming",
                "Blender",
                "Nix",
                "Criação 3D, modelagem e renderização.",
                Some("blender"),
                None,
                None,
                None,
            ),
            app(
                "creation-gimp",
                "Criação e streaming",
                "GIMP",
                "Nix",
                "Edição de imagens.",
                Some("gimp"),
                None,
                None,
                None,
            ),
            app(
                "creation-inkscape",
                "Criação e streaming",
                "Inkscape",
                "Nix",
                "Ilustração vetorial.",
                Some("inkscape"),
                None,
                None,
                None,
            ),
            app(
                "tools-virt-manager",
                "Ferramentas avançadas",
                "Virt Manager",
                "Nix",
                "Gerenciador de máquinas virtuais.",
                Some("virt-manager"),
                None,
                None,
                None,
            ),
            app(
                "tools-piper",
                "Ferramentas avançadas",
                "Piper",
                "Nix",
                "Configuração de mouses compatíveis com libratbag.",
                Some("piper"),
                None,
                None,
                None,
            ),
            app(
                "tools-gparted",
                "Ferramentas avançadas",
                "GParted",
                "Nix",
                "Editor gráfico de partições.",
                Some("gparted"),
                None,
                None,
                None,
            ),
            app(
                "remote-rustdesk",
                "Acesso remoto / suporte",
                "RustDesk",
                "Special",
                "Acesso remoto open source. Primeira opção recomendada para suporte.",
                Some("rustdesk"),
                None,
                None,
                Some("rustdesk"),
            ),
            app(
                "remote-teamviewer",
                "Acesso remoto / suporte",
                "TeamViewer",
                "Special",
                "Acesso remoto proprietário com serviço systemd quando disponível no NixOS.",
                Some("teamviewer"),
                None,
                Some("teamviewer"),
                Some("teamviewer"),
            ),
            app(
                "remote-anydesk",
                "Acesso remoto / suporte",
                "AnyDesk",
                "Special",
                "Acesso remoto proprietário com serviço systemd quando disponível no NixOS.",
                Some("anydesk"),
                None,
                Some("anydesk"),
                Some("anydesk"),
            ),
        ]
    }

    fn read_existing_nix_packages() -> BTreeSet<String> {
        let mut result = BTreeSet::new();

        let content = match fs::read_to_string(OPTIONAL_APPS_PATH) {
            Ok(content) => content,
            Err(_) => return result,
        };

        let known: BTreeSet<String> = apps()
            .into_iter()
            .filter_map(|app| app.nix_package.map(|package| package.to_string()))
            .collect();

        for line in content.lines() {
            let trimmed = line.trim();

            if trimmed.is_empty()
                || trimmed.starts_with('#')
                || trimmed.starts_with('{')
                || trimmed.starts_with('}')
                || trimmed.starts_with("let")
                || trimmed.starts_with("in")
                || trimmed.starts_with("lib.mkMerge")
                || trimmed.starts_with("environment.systemPackages")
                || trimmed.starts_with("]")
                || trimmed.starts_with("[")
                || trimmed.starts_with("(")
                || trimmed.starts_with("with pkgs")
                || trimmed.starts_with("services.")
            {
                continue;
            }

            let package = trimmed
                .trim_end_matches(';')
                .trim_end_matches(',')
                .trim()
                .to_string();

            if known.contains(&package) {
                result.insert(package);
            }
        }

        result
    }

    fn read_installed_flatpaks() -> BTreeSet<String> {
        let mut result = BTreeSet::new();

        let output = Command::new(FLATPAK)
            .arg("list")
            .arg("--system")
            .arg("--app")
            .arg("--columns=application")
            .output();

        let output = match output {
            Ok(output) if output.status.success() => output,
            _ => return result,
        };

        let stdout = String::from_utf8_lossy(&output.stdout);

        for line in stdout.lines() {
            let app_id = line.trim();

            if !app_id.is_empty() {
                result.insert(app_id.to_string());
            }
        }

        result
    }

    fn read_existing_ids() -> BTreeSet<String> {
        let existing_nix = read_existing_nix_packages();
        let existing_flatpaks = read_installed_flatpaks();
        let mut result = BTreeSet::new();

        for app in apps() {
            let mut installed = false;

            if let Some(package) = app.nix_package {
                if existing_nix.contains(package) {
                    installed = true;
                }
            }

            if let Some(flatpak_id) = app.flatpak_id {
                if existing_flatpaks.contains(flatpak_id) {
                    installed = true;
                }
            }

            if installed {
                result.insert(app.id.to_string());
            }
        }

        result
    }

    fn zenity_error(text: &str) {
        let lang = detect_lang();

        let _ = Command::new(ZENITY)
            .arg("--error")
            .arg("--width=640")
            .arg(format!("--title={}", tr(lang, "title")))
            .arg(format!("--text={}", text))
            .status();
    }

    fn zenity_info(text: &str) {
        let lang = detect_lang();

        let _ = Command::new(ZENITY)
            .arg("--info")
            .arg("--width=640")
            .arg(format!("--title={}", tr(lang, "title")))
            .arg(format!("--text={}", text))
            .status();
    }

    fn choose_apps(lang: Lang) -> Option<BTreeSet<String>> {
        let existing = read_existing_ids();

        let mut command = Command::new(ZENITY);

        command
            .arg("--list")
            .arg("--checklist")
            .arg("--width=1180")
            .arg("--height=760")
            .arg(format!("--title={}", tr(lang, "title")))
            .arg(format!("--text={}", tr(lang, "choose.text")))
            .arg(format!("--ok-label={}", tr(lang, "button.install")))
            .arg(format!("--cancel-label={}", tr(lang, "button.exit")))
            .arg("--separator=\n")
            .arg("--print-column=2")
            .arg("--hide-column=2")
            .arg(format!("--column={}", tr(lang, "col.install")))
            .arg(format!("--column={}", tr(lang, "col.id")))
            .arg(format!("--column={}", tr(lang, "col.program")))
            .arg(format!("--column={}", tr(lang, "col.origin")))
            .arg(format!("--column={}", tr(lang, "col.category")))
            .arg(format!("--column={}", tr(lang, "col.description")));

        for app in apps() {
            let checked = if existing.contains(app.id) { "TRUE" } else { "FALSE" };

            command
                .arg(checked)
                .arg(app.id)
                .arg(app_name(lang, &app))
                .arg(app.backend)
                .arg(app_category(lang, &app))
                .arg(app_description(lang, &app));
        }

        let output = match command.output() {
            Ok(output) => output,
            Err(err) => {
                zenity_error(&format!("{}:\n{}", tr(lang, "error.open_gui"), err));
                return None;
            }
        };

        if !output.status.success() {
            return None;
        }

        let stdout = String::from_utf8_lossy(&output.stdout);
        let mut selected = BTreeSet::new();

        for line in stdout.lines() {
            let id = line.trim();

            if !id.is_empty() {
                selected.insert(id.to_string());
            }
        }

        Some(selected)
    }

    fn selected_nix_packages(selected: &BTreeSet<String>) -> Vec<&'static str> {
        let mut seen = BTreeSet::new();
        let mut result = Vec::new();

        for app in apps() {
            if !selected.contains(app.id) {
                continue;
            }

            if let Some(package) = app.nix_package {
                if seen.insert(package) {
                    result.push(package);
                }
            }
        }

        result
    }

    fn selected_flatpak_ids(selected: &BTreeSet<String>) -> Vec<&'static str> {
        let mut seen = BTreeSet::new();
        let mut result = Vec::new();

        for app in apps() {
            if !selected.contains(app.id) {
                continue;
            }

            if let Some(flatpak_id) = app.flatpak_id {
                if seen.insert(flatpak_id) {
                    result.push(flatpak_id);
                }
            }
        }

        result
    }

    fn service_selected(selected: &BTreeSet<String>, service_name: &str) -> bool {
        apps()
            .iter()
            .any(|app| {
                selected.contains(app.id)
                    && app.service == Some(service_name)
            })
    }

    fn special_handlers_selected(selected: &BTreeSet<String>) -> Vec<&'static str> {
        let mut seen = BTreeSet::new();
        let mut result = Vec::new();

        for app in apps() {
            if !selected.contains(app.id) {
                continue;
            }

            if let Some(handler) = app.special_handler {
                if seen.insert(handler) {
                    result.push(handler);
                }
            }
        }

        result
    }

    fn generate_optional_apps_nix(selected: &BTreeSet<String>, lang: Lang) -> String {
        let mut out = String::new();

        out.push_str("# /etc/nixos/modules/optional-apps.nix\n");
        out.push_str("#\n");
        out.push_str("# Diesel OS Lab - GNOME Mocha Edition\n");
        out.push_str("#\n");
        out.push_str("# ");
        out.push_str(tr(lang, "optional.managed_comment"));
        out.push('\n');
        out.push_str("# ");
        out.push_str(tr(lang, "optional.chosen_comment"));
        out.push_str("\n\n");
        out.push_str("{ pkgs, lib, options, ... }:\n\n");
        out.push_str("let\n");
        out.push_str("  hasTeamViewerService = options.services ? teamviewer;\n");
        out.push_str("  hasAnyDeskService = options.services ? anydesk;\n");
        out.push_str("in\n");
        out.push_str("lib.mkMerge [\n");
        out.push_str("  {\n");
        out.push_str("    environment.systemPackages = with pkgs; [\n");

        for package in selected_nix_packages(selected) {
            out.push_str("      ");
            out.push_str(package);
            out.push('\n');
        }

        if selected.contains("tools-virt-manager") {
            for package in ["qemu", "virt-viewer", "spice", "spice-gtk", "swtpm"] {
                out.push_str("      ");
                out.push_str(package);
                out.push('\n');
            }
        }

        out.push_str("    ];\n");
        out.push_str("  }\n");

        if service_selected(selected, "teamviewer") {
            out.push_str("  (lib.optionalAttrs hasTeamViewerService {\n");
            out.push_str("    services.teamviewer.enable = true;\n");
            out.push_str("  })\n");
        }

        if service_selected(selected, "anydesk") {
            out.push_str("  (lib.optionalAttrs hasAnyDeskService {\n");
            out.push_str("    services.anydesk.enable = true;\n");
            out.push_str("  })\n");
        }

        if selected.contains("tools-virt-manager") {
            out.push_str("  {\n");
            out.push_str("    virtualisation.libvirtd.enable = true;\n");
            out.push_str("    virtualisation.spiceUSBRedirection.enable = true;\n");
            out.push_str("    users.users.hal.extraGroups = [\n");
            out.push_str("      \"libvirtd\"\n");
            out.push_str("      \"kvm\"\n");
            out.push_str("    ];\n");
            out.push_str("  }\n");
        }

        out.push_str("]\n");

        out
    }

    fn write_lines(path: &str, lines: &[&str]) -> Result<(), String> {
        let mut content = String::new();

        for line in lines {
            content.push_str(line);
            content.push('\n');
        }

        fs::write(path, content)
            .map_err(|err| format!("{} {}: {}", tr(detect_lang(), "error.write_file"), path, err))
    }

    fn write_install_script(
        temp_config: &str,
        flatpak_list: &str,
        special_list: &str,
        log_path: &str,
        script_path: &str,
        lang: Lang,
    ) -> Result<(), String> {
        let script = format!(
            r#"#!/usr/bin/env bash
set -euo pipefail

LOG="{log}"
TEMP_CONFIG="{temp_config}"
FLATPAK_LIST="{flatpak_list}"
SPECIAL_LIST="{special_list}"
DEST="{dest}"

{{
  echo "===== Mocha App Picker ====="
  echo

  if [ -f "$DEST" ] && "{cmp}" -s "$TEMP_CONFIG" "$DEST"; then
    echo "{script_no_nix_changes}"
    echo "{script_skip_rebuild}"
  else
    echo "{script_write_nix} $DEST..."

    if [ ! -s "$TEMP_CONFIG" ]; then
      echo "ERRO: arquivo temporário vazio: $TEMP_CONFIG"
      exit 1
    fi

    DEST_DIR="$("{dirname}" "$DEST")"
    DEST_TMP="$DEST_DIR/.optional-apps.nix.tmp.$$"

    "{install}" -m 0644 "$TEMP_CONFIG" "$DEST_TMP"
    "{mv}" -f "$DEST_TMP" "$DEST"

    echo
    echo "{script_apply_rebuild}"
    cd /etc/nixos

    export NIX_CONFIG='experimental-features = nix-command flakes'
    "{nixos_rebuild}" switch --flake /etc/nixos#diesel-os-lab --show-trace
  fi

  if [ -s "$SPECIAL_LIST" ]; then
    echo
    echo "{script_special_selected}"
    while IFS= read -r handler; do
      [ -z "$handler" ] && continue
      echo "  - $handler"
    done < "$SPECIAL_LIST"
    echo
    echo "{script_special_info}"
  fi

  if [ -s "$FLATPAK_LIST" ]; then
    echo
    echo "{script_ensure_flathub}"

    if ! "{flatpak}" remotes --system --columns=name | "{grep}" -qx 'flathub'; then
      "{flatpak}" remote-add --system --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi

    echo
    echo "{script_install_flatpak_selected}"

    while IFS= read -r app_id; do
      [ -z "$app_id" ] && continue

      if "{flatpak}" info --system "$app_id" >/dev/null 2>&1; then
        echo "{script_flatpak_already}: $app_id"
      else
        echo "{script_install_flatpak}: $app_id"
        "{flatpak}" install --system -y flathub "$app_id"
      fi
    done < "$FLATPAK_LIST"
  else
    echo
    echo "{script_no_flatpak}"
  fi

  echo
  echo "{script_success}"
}} > "$LOG" 2>&1
"#,
            log = log_path,
            temp_config = temp_config,
            flatpak_list = flatpak_list,
            special_list = special_list,
            dest = OPTIONAL_APPS_PATH,
            cmp = CMP,
            install = INSTALL,
            dirname = DIRNAME,
            mv = MV,
            nixos_rebuild = NIXOS_REBUILD,
            flatpak = FLATPAK,
            grep = GREP,
            script_no_nix_changes = tr(lang, "script.no_nix_changes"),
            script_skip_rebuild = tr(lang, "script.skip_rebuild"),
            script_write_nix = tr(lang, "script.write_nix"),
            script_apply_rebuild = tr(lang, "script.apply_rebuild"),
            script_special_selected = tr(lang, "script.special_selected"),
            script_special_info = tr(lang, "script.special_info"),
            script_ensure_flathub = tr(lang, "script.ensure_flathub"),
            script_install_flatpak_selected = tr(lang, "script.install_flatpak_selected"),
            script_flatpak_already = tr(lang, "script.flatpak_already"),
            script_install_flatpak = tr(lang, "script.install_flatpak"),
            script_no_flatpak = tr(lang, "script.no_flatpak"),
            script_success = tr(lang, "script.success"),
        );

        fs::write(script_path, script)
            .map_err(|err| format!("{}: {}", tr(lang, "error.prepare_script"), err))
    }

    fn tail_log(log_path: &str, lines: usize) -> String {
        let content = fs::read_to_string(log_path).unwrap_or_else(|_| String::new());

        if content.trim().is_empty() {
            return format!("{}:\n{}", tr(detect_lang(), "error.read_log"), log_path);
        }

        let all_lines: Vec<&str> = content.lines().collect();
        let start = all_lines.len().saturating_sub(lines);

        all_lines[start..].join("\n")
    }

    fn run_install(temp_config: &str, flatpak_list: &str, special_list: &str, lang: Lang) {
        let pid = std::process::id();
        let log_path = format!("/tmp/mocha-app-picker-install-{}.log", pid);
        let script_path = format!("/tmp/mocha-app-picker-install-{}.sh", pid);

        if let Err(err) = write_install_script(
            temp_config,
            flatpak_list,
            special_list,
            &log_path,
            &script_path,
            lang,
        ) {
            zenity_error(&err);
            return;
        }

        let mut progress = Command::new(ZENITY)
            .arg("--progress")
            .arg("--pulsate")
            .arg("--no-cancel")
            .arg("--width=560")
            .arg(format!("--title={}", tr(lang, "title")))
            .arg(format!("--text={}", tr(lang, "progress.installing")))
            .spawn()
            .ok();

        let status = Command::new(PKEXEC)
            .arg(BASH)
            .arg(&script_path)
            .status();

        if let Some(child) = progress.as_mut() {
            let _ = child.kill();
            let _ = child.wait();
        }

        thread::sleep(Duration::from_millis(250));

        match status {
            Ok(exit_status) if exit_status.success() => {
                zenity_info(tr(lang, "info.success"));
            }
            Ok(exit_status) => {
                let tail = tail_log(&log_path, 100);
                zenity_error(&format!(
                    "{}\n\nStatus: {}\n\n{}:\n{}",
                    tr(lang, "error.install_failed"),
                    exit_status,
                    tr(lang, "log.last_lines"),
                    tail
                ));
            }
            Err(err) => {
                zenity_error(&format!(
                    "{}:\n{}\n\n{}",
                    tr(lang, "error.auth_start"),
                    err,
                    tr(lang, "error.pkexec_missing")
                ));
            }
        }
    }

    fn main() {
        let lang = detect_lang();

        if !Path::new("/etc/nixos").exists() {
            zenity_error(tr(lang, "error.no_etc_nixos"));
            std::process::exit(1);
        }

        let selected = match choose_apps(lang) {
            Some(selected) => selected,
            None => return,
        };

        let content = generate_optional_apps_nix(&selected, lang);
        let flatpaks = selected_flatpak_ids(&selected);
        let specials = special_handlers_selected(&selected);

        let pid = std::process::id();
        let temp_config = format!("/tmp/mocha-optional-apps-{}.nix", pid);
        let flatpak_list = format!("/tmp/mocha-app-picker-flatpaks-{}.txt", pid);
        let special_list = format!("/tmp/mocha-app-picker-specials-{}.txt", pid);

        if let Err(err) = fs::write(&temp_config, content) {
            zenity_error(&format!("{}:\n{}", tr(lang, "error.prepare_optional"), err));
            return;
        }

        if let Err(err) = write_lines(&flatpak_list, &flatpaks) {
            zenity_error(&err);
            return;
        }

        if let Err(err) = write_lines(&special_list, &specials) {
            zenity_error(&err);
            return;
        }

        run_install(&temp_config, &flatpak_list, &special_list, lang);
    }
  '';

  mochaAppPicker = pkgs.runCommand "mocha-app-picker" {
    nativeBuildInputs = [
      pkgs.rustc
      pkgs.stdenv.cc
    ];
  } ''
    mkdir -p "$out/bin"
    rustc ${mochaAppPickerSrc} -O \
      -C linker=${pkgs.stdenv.cc}/bin/cc \
      -o "$out/bin/mocha-app-picker"
  '';

  mochaAppPickerDesktop = pkgs.makeDesktopItem {
    name = "mocha-app-picker";
    desktopName = "Mocha App Picker";
    genericName = "Optional Software Installer";
    comment = "Choose optional applications for Diesel OS Lab - GNOME Mocha Edition";
    exec = "mocha-app-picker";
    icon = "system-software-install";
    terminal = false;
    categories = [
      "System"
      "Settings"
    ];
  };
in
{
  environment.systemPackages = [
    mochaAppPicker
    mochaAppPickerDesktop
  ];
}
