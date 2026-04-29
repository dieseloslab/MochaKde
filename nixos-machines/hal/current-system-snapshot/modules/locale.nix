# /etc/nixos/modules/locale.nix

{
  time.timeZone = "America/Sao_Paulo";

  # Diesel OS Lab - GNOME Mocha Edition
  #
  # Base obrigatória de idiomas da ISO:
  # - pt_BR: português do Brasil
  # - en_US: inglês dos EUA / fallback obrigatório
  # - es_ES: espanhol da Espanha
  # - fr_FR: francês da França
  #
  # O sistema instalado continua usando pt_BR como padrão inicial,
  # mas a ISO e os apps próprios devem nascer preparados para os 4 idiomas.
  i18n.defaultLocale = "pt_BR.UTF-8";

  i18n.supportedLocales = [
    "pt_BR.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "es_ES.UTF-8/UTF-8"
    "fr_FR.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  console.keyMap = "br-abnt2";

  # Permite senha curta/fraca ao trocar senha via passwd.
  security.pam.services.passwd.rules.password.unix.settings.minlen = 1;

  # Faz ferramentas gráficas que usam libpwquality, como o painel de usuários
  # do GNOME, avisarem sobre senha fraca sem bloquear a alteração.
  environment.etc."security/pwquality.conf.d/90-mocha-weak-passwords.conf".text = ''
    # Diesel OS Lab - GNOME Mocha Edition
    # Do not enforce password strength in graphical tools that use libpwquality.

    enforcing = 0
    minlen = 6
    minclass = 0
    dcredit = 0
    ucredit = 0
    lcredit = 0
    ocredit = 0
    maxrepeat = 0
    maxsequence = 0
    maxclassrepeat = 0
    dictcheck = 0
    usercheck = 0
    gecoscheck = 0
  '';
}
