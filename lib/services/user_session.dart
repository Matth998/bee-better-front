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
  static int pontuacao = 0;
  static int nivel = 0;
  static int moedas = 0;

  // Salva os dados após login
  static void salvarSessao({
    required String token,
    required int id,
    required String nome,
    required String email,
    String dataNascimento = '',
    String fotoPerfil = '',
    int pontuacao = 0,
    int nivel = 0,
    int moedas = 0,
  }) {
    UserSession.token = token;
    UserSession.id = id;
    UserSession.nome = nome;
    UserSession.email = email;
    UserSession.dataNascimento = dataNascimento;
    UserSession.fotoPerfil = fotoPerfil;
    UserSession.pontuacao = pontuacao;
    UserSession.nivel = nivel;
    UserSession.moedas = moedas;
  }

  // Limpa tudo no logout
  static void limpar() {
    token = '';
    id = 0;
    nome = '';
    email = '';
    dataNascimento = '';
    fotoPerfil = '';
    pontuacao = 0;
    nivel = 0;
    moedas = 0;
  }
}