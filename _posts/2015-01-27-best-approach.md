---
layout: post
title: A good question.
categories: [research]
---

[http://www.quora.com/What-is-the-best-server-side-platform-for-developing-multi-player-games-like-words-with-friends-dots-etc](http://www.quora.com/What-is-the-best-server-side-platform-for-developing-multi-player-games-like-words-with-friends-dots-etc)

What is the best server side platform for developing multi-player games? Is the question on the forum, and what I was looking for.

It turns out the answer agreed with the rest of my research this afternoon: use a server side framework to create a RESTful API, and then
access it with Ajax requests from the client. This allows the logic to be firmly controlled by the server application, yet the client can
take any shape and form, mobile or other.
