# FeedsOfPosts

## Цель: 

1 Улучшить навыки работы с UIKit, сделав приложение для просмотра ленты tjournal.ru 

2 Поработать со смешанным API (в их API помимо ленты постов, такж присутствуют посты из Telegram, Twitter, реклама и т.п.)

- документация + роут [здесь](https://cmtt-ru.github.io/osnova-api/v2/swagger.html#/Timeline/getTimeline)

- макет для верстки ленты адаптировал на глаз [с официального приложения](https://apps.apple.com/ru/app/tjournal-новости-интернета/id683103523)

- картинки загружаются по роуту: 
https://leonardo.osnova.io/<uuid>

## Что использовал:
• Кастомные tableView cell для отображения поста, каждый элемент ячейки располагал программно с использованием Auto Layout anchors и constraint

• для создание нужного url использовал URLQueryItem

• открыл URLSession, где данные приходят в background потоке
 
• инициализировал init в структурах (Codable) для того, чтобы избежать nil при декодировании 

• Для прокрутки ленты (infinite scroll/ pagination) использовал метод делегата willDisplay
 
• для переиспользования ячеек использовал метод dequeueReusableCell
  
• обновлял ячейки с помощью reloadData, потому что это наиболее простой способ
 
• обработка касаний с помощью UITapGestureRecognizer и далее передавал событие ViewController
 
• все анимирование "распахивания" картинок вынес в отдельную функцию. Повторное касание уничтожает subView по очереди. Для blurEffect использовал autoresizingMask
 
# 1
![Screenshot 2021-08-09 at 01 41 59](https://user-images.githubusercontent.com/64494962/132016692-7b09b6ea-3151-4f83-a807-3c1132e476e1.png)
 
# 2
![Screenshot 2021-08-09 at 01 42 21](https://user-images.githubusercontent.com/64494962/132016826-4bd25ef5-68f8-48c5-8f2f-60480bdfc200.png)

## Дополнительно  
 IDE: Xcode 12.5 
 macOS: 11.4
 эмулятор iOS: 14.X
