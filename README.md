# Назначение подсистемы
Подсистема решает следующие задачи:
- обеспечения целостности данных прикладного объекта с помощью описания зависимостей между его реквизитами
- унификация доступа к данным объектов в следующих сценариях работы:
  - редактирование в управляемой форме
  - изменение со стороны подчиненной формы
  - изменение через серверную процедуру управляемой формы
  - изменение через прикладные объекты (СправочникОбъект, ДокументОбъект и т.п.)
- исключение дублирования кода:
  - при зависимости одного реквизита от нескольких
  - при одинаковых зависимостях для разных табличных частей
  - при заполнении одинаковых свойств для разных табличных частей
- исключение повторного выполнения одних и тех же обработчиков
- исключение зависимости от порядка вычислений
- возможность модульного тестирования создаваемых правил
- возможность проверки целостности данных модели

## Состав подсистемы
- ОбщийМодуль.РаботаСМоделямиГлобальный
  - процедуры области Интерфейс_Внешний предназначены для вызова из любого места основного приложения
  - процедуры области Интерфейс_Модель предназначены для вызова из модуля модели

## Внедрение подсистемы
Для описания зависимостей используются следующие объекты метаданных
- **Модуль модели** - общий модуль имеющий следующий формат имени: Модуль_<тип объекта метаданных>_<вид объекта метаданных>, у которого установлены флаги Клиент (управляемое приложение), Сервер, ВнешнееСоединение и Клиент (обычное приложение). В комментарии общего модуля можно указать опции.
В модуле модели должны быть определены следующие процедуры:
```bsl
#Область Интерфейс_МодульМодели
Процедура ПриВыполненииОбработчиков(КонтекстИзменений) Экспорт
КонецПроцедуры

Процедура ПриВыполненииОбработчиковСтроки(КонтекстИзменений, ДанныеСтроки) Экспорт
КонецПроцедуры
#КонецОбласти
```
- **Модуль формы прикладного объекта**. В формы прикладного объекта, который будет использовать подсистему должен быть добавлен следующий фрагмент кода
```bsl
#Область Интерфейс_МодульМодели
&НаКлиенте
Функция Модель_ОбработатьДействия(КонтекстИзменений) Экспорт
	Возврат Модель_ОбработатьДействияСервер(КонтекстИзменений);
КонецФункции

&НаСервере
Функция Модель_ОбработатьДействияСервер(КонтекстИзменений)
	Возврат глМодель_ОбработатьДействия(КонтекстИзменений, ЭтаФорма);
КонецФункции
#КонецОбласти
```

Также, перед первым использованием модели в форме необходимо сделать вызов процедуры *глМодель_ПриЧтенииСозданииНаСервер*
```bsl
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	глМодель_ПриЧтенииСозданииНаСервере(ЭтаФорма, Параметры.ОбъектКопирования);
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	глМодель_ПриЧтенииСозданииНаСервере(ЭтаФорма, ТекущийОбъект);
КонецПроцедуры
```

либо, если если используется процедура ПриЧтенииСозданииНаСервере
```bsl
&НаСервере
Процедура ПриЧтенииСозданииНаСервере(ОбъектСсылка)
	глМодель_ПриЧтенииСозданииНаСервере(ЭтаФорма, ОбъектСсылка);
КонецПроцедуры
```

# Основные элементы подсистемы
- **Обработчики**. Фрагменты кода на встроенном языке в модуле модели, в которых одновременно декларируется и зависимости и реализация
- **Действия**. Процедуры, описания и зависимости который выполняется в модуле модели, а реализация в модуле менеджера.
- **Дополнительные реквизиты**. Реквизиты, которые используются для удобного манипулирования данными объекта, но которые не могут быть напрямую связаны с данными объекта
- **Свойства**. Правила заполнения дополнительных реквизитов объекта, которые не сохраняются при записи объекта, а вычисляются при каждом использовании. Их описание и зависимости выполняется в модуле модели, а реализация в модуле менеджера
- **Виртуальные реквизиты**. Реквизиты, которые никак не связаны с данными, но могут инициировать выполнение обработчиков

## Обработчики
Зависимость между реквизитами шапки объекта описывается добавлением в процедуру ПриВыполненииОбработчиков модуля модели следующего фрагмента кода:
```bsl
Если глМодель_ВыполнятьОбработчик(КонтекстИзменений, <результирующие поля>, <исходные поля>) Тогда
  <реализация обработчика>
КонецЕсли;
```
Зависимость меду реквизитами табличной части объекта добавлением в процедуру ПриВыполненииОбработчиковСтроки модуля модели следующего фрагмента кода:
```bsl
Если глМодель_ВыполнятьОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, <результирующие поля>, <исходные поля>) Тогда
  <реализация обработчика>
КонецЕсли;
```

<результирующие поля> - строка со списоком реквизитов разделенных запятыми, которые изменяются при изменении зависимых полей
<исходные поля> - строка со списком реквизитов и свойств разделенных запятыми, от которых зависят результирующие поля. свойства указываются в квадратных скобках - [Свойство1],[Свойство2] и т.п.

Например для определения зависимостей Сумма = Количество * Цена и Цена = Сумма / Количество для строки табличной части необходимо добавить следующий фрагмент:
```bsl
Если глМодель_ВыполнятьОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "Сумма", "Количество,Цена") Тогда
	ДанныеСтроки.Сумма = ДанныеСтроки.Количество * ДанныеСтроки.Цена;
КонецЕсли;
Если глМодель_ВыполнятьОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "Цена", "Сумма,Количество") Тогда
	ДанныеСтроки.Цена = ДанныеСтроки.Сумма / ДанныеСтроки.Количество;
КонецЕсли;
```

Порядок описания зависимостей важен, когда определяются взаимозависимости между несколькими реквизитами. В приведенном выше примере изменение количества прежде будет изменять сумму, если поменять обработчики местами, количество будет менять цену.

Выполнятся обработчики будут в порядке разрешения зависимостей. Если разрешить зависимости не удасться, будет выдано сообщение об ошибке со списоком реквизитов необработанных зависимостей

## Действия
Действия представляют собой процедуры модуля менеджера, которые необходимо вызвать после выполнения всех обработчиков и обновления всех свойств. Это может потребоваться например для перехода от обработчиков строк к обработчикам шапки и наоборот. Действия всегда запускают новый цикл обработки изменения данных объекта. Например, обработчик изменения общей суммы транспортных расходов изменяет сумму в строке табличной части, что инициирует обработчики расчета НДС в строке.

Для реквизитов шапки обработчик описывается добавлением в процедуре ПриВыполненииОбработчиков следующего фрагмента кода:
```bsl
глМодель_ВыполнятьДействие(КонтекстИзменений, <имя действия>, <исходные реквизиты>);
```
Для реквизитов табличной части обработчик описывается добавлением в процедуре ПриВыполненииОбработчиковСтроки следующего фрагмента кода:
```bsl
глМодель_ВыполнятьДействиеСтроки(КонтекстИзменений, ДанныеСтроки, <имя действия>, <исходные реквизиты>);
```
Набор действий общий для шапки и табличных частей, при этом в рамках одного вызова действие не может инициироваться дважды, с одними и теми же параметрами
Внутри обработчика можно установить параметры, например
```bsl
Если глМодель_ВыполнятьДействие(КонтекстИзменений, "ОбновитьИтог", "Товары") Тогда
	глМодель_УстановитьПараметрДействия(КонтекстИзменений, "ИмяТаблицы", "Товары");
КонецЕсли;
```

## Дополнительные реквизиты
Для использования дополнительных реквизитов требуется для модели установить опцию **Реквизиты**. После этого в модуле менеджера необходимо описать структуру дополнительных реквизитов
```bsl
Процедура Модель_ПриИнициализации(КонтекстИзменений) Экспорт
	КонтекстТаблицы = глМодель_ДобавитьРеквизит(КонтекстИзменений, "НоменклатураДляПроверки", Новый ОписаниеТипов("ТаблицаЗначений"), "Вместе");
	глМодель_ДобавитьРеквизит(КонтекстТаблицы, "Пометка", Новый ОписаниеТипов("Булево"));
	глМодель_ДобавитьРеквизит(КонтекстТаблицы, "Номенклатура", Новый ОписаниеТипов("СправочникСсылка.Номенклатура"));
КонецПроцедуры
```
По умолчанию дополнительные реквизиты создаются без необходимости хранения. Если при создании дополнительного реквизита указан способ хранения "вместе с объектом", необходимо в модуле менеджера реализовать функционал чтения и записи
```bsl
Процедура Модель_ПриЧтении(КонтекстИзменений, ОбъектСсылка, ПослеЗаписи) Экспорт
КонецПроцедуры

Процедура Модель_ПередЗаписью(КонтекстИзменений, Объект) Экспорт
КонецПроцедуры
```

при этом в модуль формы объекта, который использует модель, необходимо добавить
```bsl
&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	глМодель_ПередЗаписьюНаСервере(ЭтаФорма, ТекущийОбъект);
КонецПроцедуры
```


Если при создании дополнительного реквизита указан способ хранения "отдельно от объекта", необходимо в модуле менеджера реализовать функционал чтения и записи
```bsl
Процедура Модель_ПриЧтении(КонтекстИзменений, ОбъектСсылка, ПослеЗаписи) Экспорт
КонецПроцедуры

Процедура Модель_ПриЗаписи(КонтекстИзменений, Ссылка) Экспорт
КонецПроцедуры
```

при этом в модуль формы объекта, который использует модель, необходимо добавить
```bsl
&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	глМодель_ПриЗаписиНаСервере(ТекущийОбъект);
КонецПроцедуры
```

Если модель содержит дополнительные реквизиты табличных частей, которые должны повторно считываться после записи объекта, в модуль формы необходимо добавить
```bsl
&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	глМодель_ПослеЗаписиНаСервере(ЭтаФорма, ТекущийОбъект);
КонецПроцедуры
```

## Свойства
Свойства представляют собой производные от реквизитов поля, которые могут использоваться как для оптимизации расчетов, так и для использования в условных оформлениях управляемых форм

Для использования свойств объекта для модели требуется установить опцию **Свойства**, а в модуле менеджера должна быть определена процедура, в которой реализуется заполнение свойств
```bsl
Процедура Модель_ПриУстановкеСвойств(КонтекстИзменений, ИменаСвойств) Экспорт
КонецПроцедуры
```
Свойство шапки описывается добавлением в процедуру ПриВыполненииОбработчиков модуля модели следующего фрагмента кода:
```bsl
глМодель_ОбновлятьСвойства(КонтекстИзменений, <имена свойств>, <исходные поля>);
```

Для использования свойств строки объекта для модели требуется установить опцию **СвойстваСтроки**, а в модуле менеджера прикладного объекта должна быть определена процедура, в которой реализуется заполнение свойств
```bsl
Процедура Модель_ПриУстановкеСвойствСтроки(КонтекстИзменений, ДанныеСтроки, ИменаСвойств) Экспорт
КонецПроцедуры
```

Свойства табличной части описываются добавлением в процедуру ПриВыполненииОбработчиковСтроки следующего фрагмента кода
```bsl
глМодель_ОбновлятьСвойстваСтроки(КонтекстИзменений, ДанныеСтроки, <имена свойств>, <исходные поля>);
```

На основании измененных реквизитов и свойств, система будет выявлять свойства для обновления, при этом обновляться они будут по принципу - как можно позже, т.е. если нет свойств, от которых зависят реквизиты, обновление свойств будет инициировано после выполнения всех обработчиков

Если модель содержит свойства табличных частей, которые должны повторно вычисляться после записи объекта, в модуль формы необходимо добавить
```bsl
&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	глМодель_ПослеЗаписиНаСервере(ЭтаФорма, ТекущийОбъект);
КонецПроцедуры
```
## Виртуальные реквизиты
Виртуальные реквизиты позволяют инициировать выполнение обработчиков строки при изменении реквизитов шапки или связанной строки и наоборот.
Для использования виртуальных реквизитов достаточно указать их в фигурных скобках в зависимом обработчике, например
```bsl
Если глМодель_ВыполнятьОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "Поставщик", "Номенклатура,{Склад}") Тогда
	ДанныеСтроки.Поставщик = ПолучитьПоставщика(ДанныеСтроки.Номенклатура, глМодель_Данные(КонтекстИзменений).Склад);
КонецЕсли;
```

Соответственно в исходном обработчике достаточно зарегистрировать изменение виртуального реквизита
```bsl
Если глМодель_ВыполнятьОбработчик(КонтекстИзменений, "Склад") Тогда
	Для Каждого СтрокаТаблицы Из глМодель_Данные(КонтекстИзменений).Товары Цикл
		глМодель_ПриИзмененииРеквизитовСтроки(КонтекстИзменений, СтрокаТаблицы, "{Склад}"
	КонецЦикла
КонецЕсли;
```

# Использование подсистемы

## Интерактивная работа в управляемой форме
Во все обработчики изменения реквизитов элементов формы, которые влияют на данные должен быть добавлен следующий вызов:
```bsl
глМодель_ПриИзмененииРеквизитов(ЭтаФорма, Элемент.Имя);
```
или
```bsl
глМодель_ПриИзмененииРеквизитовСтроки(ЭтаФорма, глМодель_ТекущиеДанные(Элемент), глМодель_ИмяРеквизита(Элемент));
```
Для табличной части необходимо также указывать обработчики ПриОконченииРедактирования и ПослеУдаления, например
```bsl
&НаКлиенте
Процедура ТоварыПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	Если РедактированиеСтрокиОтменено(Элемент, НоваяСтрока, ОтменаРедактирования) Тогда
		Возврат;
	КонецЕсли;
	
	глМодель_ПриИзмененииРеквизитов(ЭтаФорма, Элемент.Имя, СтруктураТекущиеЗначения, Элемент.ТекущиеДанные);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПослеУдаления(Элемент)
	глМодель_ПриИзмененииРеквизитов(ЭтаФорма, Элемент.Имя, СтруктураТекущиеЗначения);
КонецПроцедуры
```

## Пакетный режим изменений
Если при работе с моделью объекта предполагаются множественные изменения, рекомендуется вызвать процедуру начала работы с объектом, а при завершении работы вызвать процедуру окончения работы
Для использовании модели при работе с прикладным объектом следует придерживаться следующих правил:
  - Изменять значения реквизитов с помощью вызова функций модели. 
  - Изменять все известные реквизиты за один вызов, вместо того, чтобы изменять их по отдельности. Это позволит избежать выполнения лишних обработчиков и действий

```bsl
ДокументОбъект = глМодель_НачатьИзменения(Документы.Приход.СоздатьДокумент());
	
РеквизитыШапки = Новый Структура;
РеквизитыШапки.Вставить("Дата", ТекущаяДата());
глМодель_ИзменитьРеквизиты(ДокументОбъект, РеквизитыШапки);
	
РеквизитыСтроки = Новый Структура("Номенклатура,Количество");
Для Каждого СтрокаТаблицы Из Объект.Товары Цикл
	ЗаполнитьЗначенияСвойств(РеквизитыСтроки, СтрокаТаблицы);
	
	НоваяСтрока = ДокументОбъект.Товары.Добавить();
	глМодель_ИзменитьРеквизитыСтроки(ДокументОбъект, НоваяСтрока, РеквизитыСтроки);
КонецЦикла;
	
глМодель_ЗавершитьИзмененияИЗаписать(ДокументОбъект);
```
