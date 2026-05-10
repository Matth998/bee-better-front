class UserSession {
  // Dados de autenticação
  static String token = '';
  static int id = 0;

  // Dados do perfil
  static String nome = '';
  static String email = '';
  static String dataNascimento = '';
  static String fotoPerfil = '';

  // Gamificação
  static int nivel = 1;
  static int moedas = 0;
  static int experiencia = 0;

  // Salva os dados após login
  static void salvarSessao({
    required String token,
    required int id,
    required String nome,
    required String email,
    String birthDate = '',
    String fotoPerfil = '',
    int nivel = 1,
    int moedas = 0,
    int experiencia = 0,
  }) {
    UserSession.token = token;
    UserSession.id = id;
    UserSession.nome = nome;
    UserSession.email = email;
    UserSession.dataNascimento = birthDate;
    UserSession.fotoPerfil = fotoPerfil;
    UserSession.nivel = nivel;
    UserSession.moedas = moedas;
    UserSession.experiencia = experiencia;
  }

  // Limpa tudo no logout
  static void limpar() {
    token = '';
    id = 0;
    nome = '';
    email = '';
    dataNascimento = '';
    fotoPerfil = '';
    nivel = 1;
    moedas = 0;
    experiencia = 0;
  }
}