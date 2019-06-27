
&НаКлиенте
Процедура СоздатьПриходы(Команда)
	СоздатьОбъектыСервер();
	ОповеститьОбИзменении(Тип("ДокументСсылка.Приход"));
КонецПроцедуры

&НаСервере
Процедура СоздатьОбъектыСервер()
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
КонецПроцедуры