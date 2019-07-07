#Если НЕ Клиент ИЛИ ТолстыйКлиентОбычноеПриложение Тогда
#Область Интерфейс_МодульМодели
Процедура Модель_ПриУстановкеСвойств(КонтекстИзменений, ИменаСвойств) Экспорт
	Если глМодель_ТребуетсяУстановитьСвойства(КонтекстИзменений, "КоэффициентПересчетаСумма", ИменаСвойств) Тогда
		глМодель_УстановитьСвойство(КонтекстИзменений, "КоэффициентПересчетаСуммаРегл", 65);
	КонецЕсли;
КонецПроцедуры

Процедура Модель_ПриУстановкеСвойствСтроки(КонтекстИзменений, ДанныеСтроки, ИменаСвойств) Экспорт
	Если ДанныеСтроки = Неопределено Тогда
		Модель_ПриУстановкеСвойствСтроки(КонтекстИзменений, "Товары", ИменаСвойств);
		Возврат;
		
	ИначеЕсли ДанныеСтроки = "Товары" Тогда
		Для Каждого СтрокаТаблицы Из глМодель_Данные(КонтекстИзменений)[ДанныеСтроки] Цикл
			Модель_ПриУстановкеСвойствСтроки(КонтекстИзменений, СтрокаТаблицы, ИменаСвойств)
		КонецЦикла;
		Возврат
	КонецЕсли;
	
	Если глМодель_ТребуетсяУстановитьСвойстваСтроки(КонтекстИзменений, ДанныеСтроки, "ТипНоменклатуры", ИменаСвойств) Тогда
		глМодель_УстановитьЗначениеСвойства(КонтекстИзменений, ДанныеСтроки.Номенклатура.Тип);
	КонецЕсли;
	
	Если глМодель_ТребуетсяУстановитьСвойстваСтроки(КонтекстИзменений, ДанныеСтроки, "ДлинаТипаНоменклатуры", ИменаСвойств) Тогда
		глМодель_УстановитьЗначениеСвойства(КонтекстИзменений, СтрДлина(глМодель_ПолучитьСвойствоСтроки(КонтекстИзменений, ДанныеСтроки, "ТипНоменклатуры")));
	КонецЕсли;
КонецПроцедуры

Процедура Модель_ПриИнициализации(КонтекстИзменений) Экспорт
	глМодель_ДобавитьРеквизит(КонтекстИзменений, "КоэффициентПересчетаСуммаРегл", Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(15,3)));
	глМодель_ДобавитьРеквизит(КонтекстИзменений, "Товары.ТипНоменклатуры", Новый ОписаниеТипов("Строка"), "Нет");
	глМодель_ДобавитьРеквизит(КонтекстИзменений, "Товары.ДлинаТипаНоменклатуры", Новый ОписаниеТипов("Строка"), "Нет");
	
	КонтекстТаблицы = глМодель_ДобавитьРеквизит(КонтекстИзменений, "НоменклатураДляПроверки", Новый ОписаниеТипов("ТаблицаЗначений"), "Вместе");
	глМодель_ДобавитьРеквизит(КонтекстТаблицы, "Пометка", Новый ОписаниеТипов("Булево"));
	глМодель_ДобавитьРеквизит(КонтекстТаблицы, "Номенклатура", Новый ОписаниеТипов("СправочникСсылка.Номенклатура"));
КонецПроцедуры

Процедура Модель_ПриЧтении(КонтекстИзменений, ОбъектСсылка, ПослеЗаписи) Экспорт
	глМодель_ПолучитьСвойство(КонтекстИзменений, "НоменклатураДляПроверки").Очистить();
	ТаблицаСтроки = ОбъектСсылка.НоменклатураДляПроверки.Получить();
	Если ТаблицаСтроки <> Неопределено Тогда
		Для Каждого СтрокаТаблицы Из ТаблицаСтроки Цикл
			НоваяСтрока = глМодель_ПолучитьСвойство(КонтекстИзменений, "НоменклатураДляПроверки").Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТаблицы);
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

Процедура Модель_ПередЗаписью(КонтекстИзменений, Объект) Экспорт
	ТаблицаРезультат = Новый ТаблицаЗначений;
	Для Каждого СтруктураКолонки Из глМодель_ПолучитьДобавленныеРеквизиты(КонтекстИзменений, "НоменклатураДляПроверки") Цикл
		ТаблицаРезультат.Колонки.Добавить(СтруктураКолонки.Имя, СтруктураКолонки.ТипЗначения);
	КонецЦикла;
	
	Для Каждого СтрокаТаблицы Из глМодель_ПолучитьСвойство(КонтекстИзменений, "НоменклатураДляПроверки") Цикл
		ЗаполнитьЗначенияСвойств(ТаблицаРезультат.Добавить(), СтрокаТаблицы);
	КонецЦикла;
	
	Если ТаблицаРезультат.Количество() > 0 Тогда
		Объект.НоменклатураДляПроверки = Новый ХранилищеЗначения(ТаблицаРезультат);
	Иначе
		Объект.НоменклатураДляПроверки = Неопределено;
	КонецЕсли;
КонецПроцедуры
#КонецОбласти

Процедура ОбновитьИтоги(КонтекстИзменений, Параметры) Экспорт
	глМодель_ИзменитьРеквизит(КонтекстИзменений, "Сумма", глМодель_Данные(КонтекстИзменений).Товары.Итог("Сумма"));	
КонецПроцедуры
#КонецЕсли