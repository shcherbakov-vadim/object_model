#Область Интерфейс_МодульМодели
Процедура ПриВыполненииОбработчиков(КонтекстИзменений) Экспорт
	Объект = глМодель_Данные(КонтекстИзменений);
	Если НЕ глМодель_ОтложенноеИзменениеТаблиц(КонтекстИзменений) Тогда
		Если глМодель_ВыполнятьОбработчик(КонтекстИзменений, "Сумма", "Товары") Тогда
			Объект.Сумма = 0;
			Для Каждого СтрокаТаблицы Из Объект.Товары Цикл
				Объект.Сумма = Объект.Сумма + СтрокаТаблицы.Сумма;	
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
	Если глМодель_ВыполнятьОбработчик(КонтекстИзменений, "Товары", "Сумма") Тогда
		НакопленоСумма = 0;
		ВсегоКоличество = Объект.Товары.Итог("Количество");
		Если ВсегоКоличество > 0 Тогда
			Для Каждого СтрокаТаблицы Из Объект.Товары Цикл
				Если Объект.Товары.Индекс(СтрокаТаблицы) + 1 = Объект.Товары.Количество() Тогда
					глМодель_ИзменитьРеквизитСтроки(КонтекстИзменений, СтрокаТаблицы, "Сумма", Объект.Сумма - НакопленоСумма);
				Иначе
					глМодель_ИзменитьРеквизитСтроки(КонтекстИзменений, СтрокаТаблицы, "Сумма", СтрокаТаблицы.Количество / ВсегоКоличество * Объект.Сумма);
					НакопленоСумма = НакопленоСумма + СтрокаТаблицы.Сумма;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
	Если глМодель_ВыполнятьДействие(КонтекстИзменений, "ОбновитьИтоги", "Товары") Тогда
		ИзмененныеСтроки = глМодель_ПолучитьИзмененныеСтроки(КонтекстИзменений, "Товары");
		Если ИзмененныеСтроки <> Неопределено Тогда
			СоответствиеНомерСтроки = Новый Соответствие;
			Для Каждого КлючИЗначение Из ИзмененныеСтроки Цикл
				СоответствиеНомерСтроки.Вставить(КлючИЗначение.Ключ.НомерСтроки);
			КонецЦикла;
			
			глМодель_УстановитьПараметрДействия(КонтекстИзменений, "НомераСтрок", глМодель_ПолучитьКлючи(СоответствиеНомерСтроки));
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ПриВыполненииОбработчиковСтроки(КонтекстИзменений, ДанныеСтроки) Экспорт
	Если глМодель_ВыполнятьОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "Сумма", "Количество,Цена") Тогда
		ДанныеСтроки.Сумма = ДанныеСтроки.Количество * ДанныеСтроки.Цена;
		
		Товары = глМодель_Данные(КонтекстИзменений).Товары;
		Если Товары.Индекс(ДанныеСтроки) + 1 < Товары.Количество() Тогда
			глМодель_ИзменитьРеквизитСтроки(КонтекстИзменений, Товары[Товары.Индекс(ДанныеСтроки) + 1], "Количество", ДанныеСтроки.Количество + 1);
		КонецЕсли;
	КонецЕсли;
		
	Если глМодель_ВыполнятьОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "СуммаРегл", "Сумма") Тогда
		ДанныеСтроки.СуммаРегл = ДанныеСтроки.Сумма * глМодель_ПолучитьСвойство(КонтекстИзменений, "КоэффициентПересчетаСуммаРегл");
	КонецЕсли;
		
	Если глМодель_ВыполнятьОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "СуммаЗакупки", "Количество,ЦенаЗакупки") Тогда
		ДанныеСтроки.СуммаЗакупки = ДанныеСтроки.Количество * ДанныеСтроки.ЦенаЗакупки;
	КонецЕсли;
		
	Если глМодель_ВыполнятьОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "Наценка", "Сумма,СуммаЗакупки") Тогда
		Если ДанныеСтроки.СуммаЗакупки = 0 Тогда
			ДанныеСтроки.Наценка = 0;
		Иначе
			ДанныеСтроки.Наценка = (ДанныеСтроки.Сумма - ДанныеСтроки.СуммаЗакупки) / ДанныеСтроки.СуммаЗакупки * 100;
		КонецЕсли;
	КонецЕсли;
		
	Если глМодель_ВыполнятьОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "Цена", "Номенклатура,[ТипНоменклатуры]", "_Сервер_") Тогда
		#Если НЕ Клиент ИЛИ ТолстыйКлиентОбычноеПриложение Тогда
		ТаблицаСтроки = РегистрыСведений.ЦеныНоменклатуры.СрезПоследних(глМодель_Данные(КонтекстИзменений).Дата, Новый Структура("Номенклатура", ДанныеСтроки.Номенклатура));
		Если ТаблицаСтроки.Количество() > 0 Тогда
			ДанныеСтроки.Цена = ТаблицаСтроки[0].Цена;
		Иначе
			ДанныеСтроки.Цена = 0;
		КонецЕсли;
		#КонецЕсли
	КонецЕсли;
		
	Если глМодель_ВыполнятьОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "Цена", "Сумма,Количество") Тогда
		Если ДанныеСтроки.Количество = 0 Тогда
			ДанныеСтроки.Цена = ДанныеСтроки.Сумма;
		Иначе
			ДанныеСтроки.Цена = ДанныеСтроки.Сумма / ДанныеСтроки.Количество;
		КонецЕсли;
	КонецЕсли;
		
	Если глМодель_ВыполнятьОбработчикСтроки(КонтекстИзменений, ДанныеСтроки, "ЦенаЗакупки", "СуммаЗакупки,Количество") Тогда
		Если ДанныеСтроки.Количество = 0 Тогда
			ДанныеСтроки.ЦенаЗакупки = ДанныеСтроки.СуммаЗакупки;
		Иначе
			ДанныеСтроки.ЦенаЗакупки = ДанныеСтроки.СуммаЗакупки / ДанныеСтроки.Количество;
		КонецЕсли;
	КонецЕсли;
	
	глМодель_ОбновлятьСвойстваСтроки(КонтекстИзменений, ДанныеСтроки, "ТипНоменклатуры", "Номенклатура");
	глМодель_ОбновлятьСвойстваСтроки(КонтекстИзменений, ДанныеСтроки, "ДлинаТипаНоменклатуры", "[ТипНоменклатуры]");
КонецПроцедуры
#КонецОбласти