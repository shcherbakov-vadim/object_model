&НаКлиенте
Перем СтруктураТекущиеЗначения;

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

&НаКлиенте
Процедура ТоварыНоменклатураПриИзменении(Элемент)
	глМодель_ПриИзмененииРеквизитовСтроки(ЭтаФорма, глМодель_ТекущиеДанные(Элемент), "Номенклатура");
КонецПроцедуры

&НаКлиенте
Процедура ТоварыКоличествоПриИзменении(Элемент)
	глМодель_ПриИзмененииРеквизитовСтроки(ЭтаФорма, глМодель_ТекущиеДанные(Элемент), "Количество");
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаПриИзменении(Элемент)
	глМодель_ПриИзмененииРеквизитовСтроки(ЭтаФорма, глМодель_ТекущиеДанные(Элемент), "Цена");
КонецПроцедуры

&НаКлиенте
Процедура ТоварыСуммаПриИзменении(Элемент)
	глМодель_ПриИзмененииРеквизитовСтроки(ЭтаФорма, глМодель_ТекущиеДанные(Элемент), "Сумма");
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПередУдалением(Элемент, Отказ)
	СохранитьЗначенияСтроки(Элемент);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	СохранитьЗначенияСтроки(Элемент);
КонецПроцедуры

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

&НаКлиенте
Процедура ЗаполнитьТовары(Команда)
	ЗаполнитьТоварыСервер()	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТоварыСервер()
	РеквизитыСтроки = Новый Структура;
	РеквизитыСтроки.Вставить("Номенклатура", Справочники.Номенклатура.НайтиПоНаименованию("Номенклатура 1"));
	РеквизитыСтроки.Вставить("Количество", 3);
	
	КонтекстИзменений = глМодель_НачатьИзменения(ЭтаФорма);
	НоваяСтрока = Объект.Товары.Добавить();
	глМодель_ИзменитьРеквизитыСтроки(КонтекстИзменений, НоваяСтрока, РеквизитыСтроки);
	глМодель_ЗавершитьИзменения(КонтекстИзменений);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьПодбор(Команда)
	ОткрытьФорму("Обработка.ПодборТоваров.Форма", , ЭтаФорма);
КонецПроцедуры

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
	Если НЕ СлужебныеРеквизитыИнициализированы Тогда
		СлужебныеРеквизитыИнициализированы = Истина;
		
		Для Каждого МетаданныеТЧ Из Объект.Ссылка.Метаданные().ТабличныеЧасти Цикл
			ДобавитьПоляКоллекции("Объект." + МетаданныеТЧ.Имя);
		КонецЦикла;
	КонецЕсли;

	глМодель_ПриЧтенииСозданииНаСервере(ЭтаФорма, ОбъектСсылка);
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	глМодель_ПередЗаписьюНаСервере(ЭтаФорма, ТекущийОбъект);
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	глМодель_ПослеЗаписиНаСервере(ЭтаФорма, ТекущийОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ТоварыЦенаЗакупкиПриИзменении(Элемент)
	глМодель_ПриИзмененииРеквизитовСтроки(ЭтаФорма, глМодель_ТекущиеДанные(Элемент), "ЦенаЗакупки");
КонецПроцедуры

&НаКлиенте
Процедура ТоварыСуммаЗакупкиПриИзменении(Элемент)
	глМодель_ПриИзмененииРеквизитовСтроки(ЭтаФорма, глМодель_ТекущиеДанные(Элемент), "СуммаЗакупки");
КонецПроцедуры

&НаКлиенте
Процедура СохранитьЗначенияСтроки(Элемент)
	Если Элемент.ВыделенныеСтроки.Количество() = 1 Тогда
		СтруктураТекущиеЗначения = ПолучитьСтруктуруСтроки("Объект." + Элемент.Имя);
		ЗаполнитьЗначенияСвойств(СтруктураТекущиеЗначения, Элемент.ТекущиеДанные);
	Иначе
		СтруктураТекущиеЗначения = Неопределено;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция ПолучитьСтруктуруСтроки(ИмяКоллекции)
	СтруктураРезультат = Новый Структура;
	Для Каждого СтрокаТаблицы Из ТаблицаПоляКоллекций.НайтиСтроки(Новый Структура("Коллекция", ИмяКоллекции)) Цикл
		СтруктураРезультат.Вставить(СтрокаТаблицы.Поле);	
	КонецЦикла;
	
	Возврат СтруктураРезультат;
КонецФункции

&НаКлиенте
Функция РедактированиеСтрокиОтменено(Элемент, НоваяСтрока, ОтменаРедактирования)
	Если НЕ НоваяСтрока
		И ОтменаРедактирования Тогда
		
		Если СтруктураТекущиеЗначения <> Неопределено Тогда
			ЗаполнитьЗначенияСвойств(Элемент.ТекущиеДанные, СтруктураТекущиеЗначения);
		КонецЕсли;
	КонецЕсли;
	
	Возврат ОтменаРедактирования;
КонецФункции

&НаСервере
Процедура ДобавитьПоляКоллекции(ИмяКоллекции)
	МассивРеквизиты = ПолучитьРеквизиты(ИмяКоллекции);
	Для Каждого РеквизитФормы Из МассивРеквизиты Цикл
		НоваяСтрока = ТаблицаПоляКоллекций.Добавить();
		НоваяСтрока.Коллекция = ИмяКоллекции;
		НоваяСтрока.Поле = РеквизитФормы.Имя;
	КонецЦикла;
КонецПроцедуры
