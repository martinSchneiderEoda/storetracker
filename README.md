## Inspiration

Social Distancing und Hamsterkäufe machen derzeit Supermarkt Besuche zu einer alltäglichen Herausforderung. Ziel der Lösung ist es dabei zu helfen, den Besuch von überfüllten Märkten zu vermeiden und dennoch alle nötigen Produkte zu finden.

## Was ist der Storetracker?

Der Storetracker ist eine Webapp, die auf eine Nutzung mit Mobilgeräten optimiert ist. Der Storetracker gibt auf Basis des Bedarfs, der Uhrzeit und der Position des Users eine Empfehlung, welcher Supermarkt am ehesten besucht werden sollte. Die Empfehlung basiert auf einem Score der sich aus Distanz, Marktauslastung und Vorratsmenge der gewünschten Produkte berechnet.

## Was macht den Storetracker so besonders?

Die Datenbasis wird von den Usern selbst gepflegt - nach einem Supermarkt Besuch können User ganz einfach die aktuelle Marktauslastung und den Vorrat an Produkten bewerten. Die App basiert also auf einem gemeinschaftlichen und solidarischen Grundgedanken: Je mehr Leute die App benutzen und Supermärkte bzw. Produktverfügbarkeiten bewerten, desto nützlicher ist die App für jeden einzelnen Nutzer.

Darüber hinaus bietet der Storetracker die Möglichkeit die Auslastung von Märkten und die Verfügbarkeit von Produkten im Laufe der Zeit und für die Zukunft zu betrachten. Die Prognosen für zukünftige Zeitpunkte basieren auf den bisherigen Nutzereingaben und werden von Machine Learning Algorithmen berechnet. Eine verlässliche Prognose führt dazu, dass die Nutzer nicht in überfüllte Supermärkte gehen oder vor leeren Regalen stehen.

## Wie haben wir den Storetracker entwickelt
Die Lösung wurde mit R shiny entwickelt und greift zusätzlich auf leaflet.js zu. Zur Kartendarstellung und Identifizierung von Supermärkten haben wir openstreetmap verwendet. Die Daten werden in einer SQLite Tabelle gespeichert. Die Auslastungs- und Verfügbarkeitsdaten wurden für einige Supermärkte für einen Zeitraum von einer Woche simuliert. Die Produkte bestehen aus einer kleinen Auswahl gängiger Supermarktartikel.

Somit basiert der storetracker nur auf Open Source Tools und basiert neben des Abrufens von Geodaten zu Supermärkten, sowie dem Anlegen einer initialen Produktdatenbank lediglich auf von den Nutzern eingegebenen Daten.

## Wie sieht die Zukunft des Storetrackers aus?
Zunächst sollte die App so schnell wie möglich für eine große Nutzergruppe zugänglich gemacht werden, um eine gute Datengrundlage zu erzeugen. Dafür muss eine mobile app in Anlehnung an die prototypische Shiny-App entwickelt werden und die Supermakt- und Produktdatenbank erweitert werden. Sobald eine ausreichende Datengrundlage vorhanden ist, kann ein robusten und verlässliches Machine Learning Modell entwickelt werden, welches eine gute Prognose für die zukünftige Auslastung bzw. Produktverfügbarkeit liefert. Außerdem kann die nutzerbasierte Priorisierungslogik erweitert werden, sodass die Verfügbarkeit bestimmter Produkte stärker gewichtet und bei der Marktempfehlung eher berücksichtigt wird.

Sobald die App in dieser Grundversion vorliegt, kann sie um weitere Features erweitert werden. Perspektivisch sollen beispielsweise Information wie Warenlieferungen von Supermärkten in die Prognose miteinfließen. Dies kann zeitnah durch einen User-Input für Supermarktleiter umgesetzt werden, die die Daten der Warenlieferungen im Vorfeld angeben. Außerdem sollen Supermarktleiter selbst eine Einschätzung der Produktverfügbarkeit bzw. der Auslastung ihres Marktes angeben können. Dies setzt die Festlegung besonderer User innerhalb der App voraus, deren Eingabe stärker gewichtet wird. Außerdem kann die Ermittlung Auslastung neben den User-Einschätzungen durch anonymisierte Bewegungsdaten verbessert werden.
Prototyp unter [link] (https://supermarketlocator.shinyapps.io/storetrackeR/)

## Video
[https://www.youtube.com/watch?v=UWoYcCzhSO4]

