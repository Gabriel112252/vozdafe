# Original reflections and scripture references; no invented literal Bible quotation.
require "securerandom"
require "time"
class DevotionalGenerator
  LIMIT = 500
  THEMES = {
    ansiedade: {
      keywords: %w[ansioso ansiosa ansiedade preocupado preocupada medo nervoso inseguro preocupacao pressao estresse],
      title: "Você não precisa carregar tudo sozinho", verse_reference: "Filipenses 4:6-7",
      reflection: "Nem todas as respostas precisam chegar hoje. Quando o futuro pesa, a oração pode ser um espaço para reconhecer seus limites e encontrar paz para o próximo passo. Deus conhece aquilo que você ainda não consegue organizar em palavras. Caminhe um dia de cada vez.",
      prayer: "Senhor, entrego a Ti as preocupações que apertam meu coração. Dá-me serenidade para o que não controlo, coragem para o que posso fazer e sabedoria para reconhecer Tua presença hoje. Amém.",
      practice: "Anote uma preocupação e uma pequena ação possível para hoje."
    },
    tristeza: {
      keywords: %w[triste tristeza chorar chorei sozinho sozinha solida solitario luto perda saudade desanimado desanimada],
      title: "Há acolhimento para o seu coração", verse_reference: "Salmos 34:18",
      reflection: "A tristeza não é sinal de pouca fé. Existem dias em que o coração precisa de silêncio, cuidado e companhia. A Escritura apresenta um Deus próximo de quem está ferido. Você não precisa fingir força: permita-se ser cuidado e peça ajuda a alguém de confiança.",
      prayer: "Deus de consolo, recebe minhas lágrimas e a dor que ainda não sei explicar. Aproxima de mim pessoas que tragam cuidado e renova, pouco a pouco, minha esperança. Amém.",
      practice: "Converse com alguém de confiança e permita-se descansar sem culpa."
    },
    gratidao: {
      keywords: %w[grato grata obrigado obrigada gratidao feliz alegria conquista vitoria abencoado abencoada],
      title: "Reconheça as pequenas bênçãos", verse_reference: "1 Tessalonicenses 5:18",
      reflection: "A gratidão nos ajuda a perceber a graça no cotidiano: nas pessoas, no alimento, nas portas abertas e até nos pequenos recomeços. Celebre o bem que chegou sem esquecer daqueles que precisam de apoio. A alegria cresce quando é compartilhada.",
      prayer: "Pai, obrigado pelas dádivas que recebi, inclusive as discretas. Ensina-me a viver com generosidade e a transformar minha alegria em cuidado pelo próximo. Amém.",
      practice: "Agradeça diretamente a uma pessoa que fez diferença no seu dia."
    },
    decisao: {
      keywords: %w[decisao decidir escolher escolha trabalho emprego caminho duvida futuro mudanca mudar],
      title: "Sabedoria para o próximo passo", verse_reference: "Tiago 1:5",
      reflection: "Não é preciso conhecer o caminho inteiro para dar um passo responsável. Buscar sabedoria inclui orar, ouvir conselhos e examinar as opções com calma. A fé não elimina a necessidade de decidir; ela pode ajudar a fazê-lo com honestidade e coragem.",
      prayer: "Senhor, orienta meu coração nesta escolha. Dá-me clareza para avaliar caminhos, humildade para buscar bons conselhos e paz para agir com responsabilidade. Amém.",
      practice: "Escreva duas opções e converse sobre elas com alguém sensato."
    },
    esperanca: {
      keywords: %w[esperanca cansado cansada dificil dificuldade fracasso recomecar recomeco sem forca desmotivado],
      title: "Ainda há um novo começo", verse_reference: "Isaías 40:31",
      reflection: "O cansaço pode tornar tudo mais distante, mas não define seu valor nem seu futuro. A imagem bíblica da esperança fala de forças renovadas. Respeite o ritmo do seu corpo, procure apoio e lembre-se: recomeços também acontecem em passos pequenos.",
      prayer: "Deus, renova minha esperança quando as forças parecem pequenas. Ajuda-me a descansar, aceitar cuidado e encontrar coragem para continuar. Amém.",
      practice: "Escolha uma tarefa pequena e possível, sem exigir perfeição."
    }
  }.freeze

  def self.call(message)
    text = message.to_s.strip
    raise ArgumentError, "Escreva ou diga como você está se sentindo." if text.empty?
    raise ArgumentError, "A mensagem deve ter no máximo #{LIMIT} caracteres." if text.length > LIMIT

    normalized = text.downcase.unicode_normalize(:nfkd).gsub(/\p{Mn}/, "")
    score = lambda do |theme|
      theme[:keywords].count { |word| normalized.match?(/(?<![[:alpha:]])#{Regexp.escape(word)}(?![[:alpha:]])/) }
    end
    name, data = THEMES.max_by { |_name, entry| score.call(entry) }
    name, data = [:esperanca, THEMES[:esperanca]] if score.call(data).zero?

    {
      id: SecureRandom.uuid, theme: name.to_s, title: data[:title],
      verse_reference: data[:verse_reference], reflection: data[:reflection],
      prayer: data[:prayer], practice: data[:practice],
      created_at: Time.now.utc.iso8601
    }
  end
end
