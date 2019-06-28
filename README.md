# Назначение подсистемы
Подсистема решает следующие задачи:
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

Для обеспечения целостности данных прикладного объекта подсистема предоставляет возможность описать зависимости между его реквизитами, описать дополнительные свойства и действия.

## Состав подсистемы
- ОбщийМодуль.РаботаСМоделямиГлобальный
  - процедуры области Интерфейс_Внешний предназначены для вызова из любого места основного приложения
  - процедуры области Интерфейс_Модель предназначены для вызова из модуля модели
- ОбщийМодуль.РаботаСМоделямиВызовСервера - служебные процедуры

## Описание зависимостей
Для описания зависимостей используются следующие объекты метаданных
- **Модуль модели** - общий модуль имеющий следующий формат имени: Модуль_<тип объекта метаданных>_<вид объекта метаданных>КлиентСервер, у которого установлены флаги Клиент (управляемое приложение), Сервер, ВнешнееСоединение и Клиент (обычное приложение)
В модуле модели должны быть определены следующие процедуры:
```bsl
#Область Интерфейс_МодульМодели
Процедура ПриВыполненииОбработчиков(КонтекстИзменений, ДанныеСтрокиСтарые = Неопределено, ДанныеСтрокиНовые = Неопределено) Экспорт
КонецПроцедуры

Процедура ПриВыполненииОбработчиковСтроки(КонтекстИзменений, ДанныеСтроки) Экспорт
КонецПроцедуры
#КонецОбласти
```
- **Модуль менеджера прикладного объекта**. В каждом модуле менеджера должны быть определены следующие процедуры
```bsl
#Область Интерфейс_МодульМодели
Процедура Модель_ПриУстановкеСвойств(КонтекстИзменений, ИменаСвойств) Экспорт
КонецПроцедуры

Процедура Модель_ПриУстановкеСвойствСтроки(КонтекстИзменений, ДанныеСтроки, ИменаСвойств) Экспорт
КонецПроцедуры
#КонецОбласти
```
- В каждый модуль формы объекта метаданных, который будет использовать подсистему должен быть добавлен следующий фрагмент кода
```bsl
#Область Подсистема_МодульМодели
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

# Основные элементы подсистемы
- **Обработчики**. Фрагменты кода на встроенном языке в модуле модели, в которых одновременно декларируется и зависимости и реализация
- **Свойства**. Дополнительные реквизиты шапки или табличных частей, которые на управляемой форме представляют собой дополнительные свойства объектов ДанныеФормаСтруктура или ДанныеФормыКоллекция. Их описание и зависимости выполняется в модуле модели, а реализация в модуле менеджера
- **Действия**. Процедуры, описания и зависимости который выполняется в модуле модели, а реализация в модуле менеджера.

## Обработчики
Зависимость между реквизитами шапки объекта описывается добавлением в процедуру ПриВыполненииОбработчиков модуля модели следующего фрагмента кода:
```bsl
Если глМодель_ВыполняетсяОбработчик(КонтекстИзменений, <результирующие поля>, <зависимые поля>) Тогда
  <реализация обработчика>
КонецЕсли;
```
Зависимость меду реквизитами табличной части объекта добавлением в процедуру ПриВыполненииОбработчиковСтроки модуля модели следующего фрагмента кода:
```bsl
Если глМодель_ВыполняетсяОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, <результирующие поля>, <зависимые поля>) Тогда
  <реализация обработчика>
КонецЕсли;
```

<результирующие поля> - строка со списоком реквизитов разделенных запятыми, которые изменяются при изменении зависимых полей
<зависимые поля> - строка со списком реквизитов и свойств разделенных запятыми, от которых зависят результирующие поля. свойства указываются в квадратных скобках - [Свойство1],[Свойство2] и т.п.

Например для определения зависимостей Сумма = Количество * Цена и Цена = Сумма / Количество для строки табличной части необходимо добавить следующий фрагмент:
```bsl
Если глМодель_ВыполняетсяОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "Сумма", "Количество,Цена") Тогда
	ДанныеСтроки.Сумма = ДанныеСтроки.Количество * ДанныеСтроки.Цена;
КонецЕсли;
Если глМодель_ВыполняетсяОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "Цена", "Сумма,Количество") Тогда
	ДанныеСтроки.Сумма = ДанныеСтроки.Количество * ДанныеСтроки.Цена;
КонецЕсли;
```

Порядок описания зависимостей важен, когда определяются взаимозависимости между несколькими реквизитами. В приведенном выше примере изменение количества прежде будет изменять сумму, если поменять обработчики местами, количество будет менять цену.

Выполнятся обработчики будут в порядке разрешения зависимостей. Если разрешить зависимости не удасться, будет выдано сообщение об ошибке со списоком реквизитов необработанных зависимостей

## Свойства
Свойства представляют собой производные от реквизитов поля, которые могут использоваться как для оптимизации расчетов, так и для использования в условных оформлениях управляемых форм

Свойство шапки описывается добавлением в процедуру ПриВыполненииОбработчиков модуля модели следующего фрагмента кода:
```bsl
глМодель_ОбновлятьСвойства(КонтекстИзменений, <имена свойств>, <зависимые поля>);
```

Свойства табличной части описываются добавлением в процедуру ПриВыполненииОбработчиковСтроки следующего фрагмента кода
```bsl
глМодель_ОбновлятьСвойстваСтроки(КонтекстИзменений, ДанныеСтроки, <имена свойств>, <зависимые поля>);
```

На основании измененных реквизитов и свойств, система будет выявлять свойства для обновления, при этом обновляться они будут по принципу - как можно позже, т.е. если нет свойств, от которых зависят реквизиты, обновление свойств будет инициировано после выполнения всех обработчиков

## Действия
Действия представляют собой процедуры модуля менеджера, которые необходимо вызвать после выполнения всех обработчиков и обновления всех свойств. Это может потребоваться например для перехода от обработчиков строк к обработчикам шапки и наоборот. Действия всегда запускают новый цикл обработки изменения данных объекта. Например, обработчик изменения общей суммы транспортных расходов изменяет сумму в строке табличной части, что инициирует обработчики расчета НДС в строке.

Для реквизитов шапки обработчик описывается добавлением в процедуре ПриВыполненииОбработчиков следующего фрагмента кода:
```bsl
глМодель_ВыполнятьДействие(КонтекстИзменений, <имя действия>, <зависимые параметры>);
```
Для реквизитов табличной части обработчик описывается добавлением в процедуре ПриВыполненииОбработчиковСтроки следующего фрагмента кода:
```bsl
глМодель_ВыполнятьДействиеСтроки(КонтекстИзменений, ДанныеСтроки, <имя действия>, <зависимые параметры>);
```
Набор действий общий для шапки и табличных частей, при этом в рамках одного вызова действие не может инициироваться дважды, с одними и теми же параметрами
Внутри обработчика можно установить параметры, например
```bsl
Если глМодель_ВыполнятьДействие(КонтекстИзменений, "ОбновитьИтог", "Товары") Тогда
	глМодель_УстановитьПараметрДействия(КонтекстИзменений, "ИмяТаблицы", "Товары");
КонецЕсли;
```

В процессе выполнения обработчиков может оказаться, что действие более не актуально, поэтому можно указать условие при котором действие выполнять не нужно, например:
```bsl
Если глМодель_ВыполнятьДействиеСтроки(КонтекстИзменений, ДанныеСтроки, "РаспределитьДлительность", "Количество") Тогда
	Если НЕ глМодель_Данные(КонтекстИзменений).РаспределятьДлительность Тогда
		глМодель_УдалитьДействие(КонтекстИзменений);
  	КонецЕсли;
КонецЕсли;
```

# Использование подсистемы

## Интерактивная работа в управляемой форме
Во все обработчики изменения реквизитов элементов формы, которые влияют на данные должен быть добавлен следующий вызов:
```bsl
глМодель_ПриИзмененииРеквизитов(ЭтаФорма, глМодель_ИмяРеквизита(Элемент));
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

Так как при использовании модели в управляемой форме свойства хранятся в реквизитах шапки и табличных частей необходимо их заполнять при создании и чтении. Также необходимо обновлять свойства табличных частей, из-за особенностей работы платформы
```bsl
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ПриЧтенииСозданииНаСервере(Параметры.ОбъектКопирования);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	ПриЧтенииСозданииНаСервере(ТекущийОбъект);
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииСозданииНаСервере(ОбъектСсылка)
	глМодель_ОбновитьСвойства(ЭтаФорма);
	глМодель_ОбновитьСвойстваСтроки(ЭтаФорма);
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	глМодель_ОбновитьСвойстваСтроки(ЭтаФорма);
КонецПроцедуры
```

## Пакетный режим изменений
Если при работе с моделью объекта предполагаются множественные изменения, рекомендуется вызвать процедуру начала работы с объектом, а при завершении работы вызвать процедуру окончения работы
Для использовании модели при работе с прикладным объектом следует придерживаться следующих правил:
  - Изменять значения реквизитов с помощью вызова функций модели. 
  - После изменения табличной части необходимо также объявлять о ее завершении
  - Изменять все известные реквизиты за один вызов, вместо того, чтобы изменять их по отдельности. Это позволит избежать выполнения лишних обработчиков и действий

```bsl
ДокументОбъект = Документы.Приход.СоздатьДокумент();
КонтекстИзменений = глМодель_НачатьИзменения(ДокументОбъект);
	
РеквизитыШапки = Новый Структура;
РеквизитыШапки.Вставить("Дата", ТекущаяДата());
глМодель_ИзменитьРеквизиты(КонтекстИзменений, РеквизитыШапки);
	
РеквизитыСтроки = Новый Структура("Номенклатура,Количество");
Для Каждого СтрокаТаблицы Из Объект.Товары Цикл
	ЗаполнитьЗначенияСвойств(РеквизитыСтроки, СтрокаТаблицы);
	
	НоваяСтрока = ДокументОбъект.Товары.Добавить();
	глМодель_ИзменитьРеквизитыСтроки(КонтекстИзменений, НоваяСтрока, РеквизитыСтроки);
КонецЦикла;
	
глМодель_ПриИзмененииРеквизитов(КонтекстИзменений, "Товары");
глМодель_ЗавершитьИзменения(КонтекстИзменений);
	
ДокументОбъект.Записать();
```
