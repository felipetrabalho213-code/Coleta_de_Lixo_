class HomeController {
  // Dados do Usuário (em um app real viriam do Firebase/API)
  String nomeUsuario = "Felipe Albuquerque";
  String enderecoUsuario = "Jaboatão dos Guararapes - PE";
  
  // Status da Coleta
  bool caminhaoProximo = true;
  String proximaColetaHorario = "Hoje às 14:00";

  // Retorna os cards/opções de atalho da Home
  List<Map<String, String>> obterAtalhosHome() {
    return [
      {
        'titulo': 'Calendário',
        'subtitulo': 'Dias e horários da coleta',
        'icone': 'calendar',
      },
      {
        'titulo': 'Ver Caminhão',
        'subtitulo': 'Acompanhe em tempo real',
        'icone': 'truck',
      },
      {
        'titulo': 'Coleta Especial',
        'subtitulo': 'Agende a retirada de entulhos',
        'icone': 'special',
      },
      {
        'titulo': 'Notificações',
        'subtitulo': 'Alertas e avisos importantes',
        'icone': 'notification',
      },
    ];
  }
}