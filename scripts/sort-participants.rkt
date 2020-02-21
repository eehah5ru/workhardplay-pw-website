#lang racket

(define participants-ru
  (list
   "Марийка Семененко"
   "Техно-Поэзия"
   "Masque Noir"
   "Алиса Олева"
   "Группировка eeefff"
   "Михаил Гулин"
   "Василиса Полянина"
   "Роман Осьминкин"
   "Алексей Борисенок"
   "Алексей Толстов"
   "Анна Хуана"
   "Антон Сорокин"
   "Летучая кооперация"
   "Инга Линдоренко"
   "Лена Клабукова "
   "Надя Дегтярева"
   "Ник Дегтярев"
   "Павел Хайло"
   "Ульяна Быченкова"
   "Алексей Наумчик"
   "Максим Сарычев"
   "Vox Studio"
   "Виржиль Наварина"
   "Жан Себан"
   "Таня Эфрусси"))

(define participants-en
  (list
   "Maria Semenenko"
   "Techno-Poetry"
   "Masque Noir"
   "Alisa Oleva"
   "eeefff"
   "Mikhail Gulin"
   "Vasilisa Polianina"
   "Roman Osminkin"
   "Aleksei Borisionok"
   "Aliaxey Talstou"
   "Anna Huana "
   "Anton Sorokin "
   "Flying cooperation"
   "Inga Lindorenko"
   "Lena Klabukova"
   "Nadia Degtyareva"
   "Nick Degtyarev"
   "Pavel Khailo"
   "Uliana Bychenkova"
   "Aleksei Naumchik"
   "Maksim Sarychev"
   "Vox Studio"
   "Virgile Novarina"
   "Jean Seban"
   "Tatiana Efrussi"
   ))

(define (extract-sort-word participants)
  (map (compose1 last
                 string-split)
       participants))

(define (display-sort-word participants)
  (for ([p (extract-sort-word participants)])
    (displayln p)))
