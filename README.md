# FeedsOfPosts

## Цель: 

1 Улучшить навыки работы с UIKit, сделав приложение для просмотра ленты tjournal.ru 

2 Поработать со смешанным API (в их API помимо ленты постов, такж присутствуют посты из Telegram, Twitter, реклама и т.п.)

• документация + роут [здесь](https://cmtt-ru.github.io/osnova-api/v2/swagger.html#/Timeline/getTimeline)

## Что использовал:
• tableView для представления поста, каждый элемент ячейки располагал программно с использованием Auto Layout anchors и constraint

• для создание нужного url использовать URLQueryItem

• использовал URLSession, где данные приходят в background потоке

• Для прокрутки ленты (infinite scroll/ pagination) использовал метод делегата willDisplay

