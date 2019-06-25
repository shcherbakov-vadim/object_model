Функция МенеджерОбъектаПоПолномуИмени(ПолноеИмя) Экспорт
	Перем КлассОМ, ИмяОМ, Менеджер;
	
	ЧастиИмени = СтрРазделить(ПолноеИмя, ".");
	
	Если ЧастиИмени.Количество() >= 2 Тогда
		КлассОМ = ЧастиИмени[0];
		ИмяОМ  = ЧастиИмени[1];
	КонецЕсли;
	
	Если      ВРег(КлассОМ) = "ПЛАНОБМЕНА" Тогда
		Менеджер = ПланыОбмена;
		
	ИначеЕсли ВРег(КлассОМ) = "СПРАВОЧНИК" Тогда
		Менеджер = Справочники;
		
	ИначеЕсли ВРег(КлассОМ) = "ДОКУМЕНТ" Тогда
		Менеджер = Документы;
		
	ИначеЕсли ВРег(КлассОМ) = "ЖУРНАЛДОКУМЕНТОВ" Тогда
		Менеджер = ЖурналыДокументов;
		
	ИначеЕсли ВРег(КлассОМ) = "ПЕРЕЧИСЛЕНИЕ" Тогда
		Менеджер = Перечисления;
		
	ИначеЕсли ВРег(КлассОМ) = "ОТЧЕТ" Тогда
		Менеджер = Отчеты;
		
	ИначеЕсли ВРег(КлассОМ) = "ОБРАБОТКА" Тогда
		Менеджер = Обработки;
		
	ИначеЕсли ВРег(КлассОМ) = "ПЛАНВИДОВХАРАКТЕРИСТИК" Тогда
		Менеджер = ПланыВидовХарактеристик;
		
	ИначеЕсли ВРег(КлассОМ) = "ПЛАНСЧЕТОВ" Тогда
		Менеджер = ПланыСчетов;
		
	ИначеЕсли ВРег(КлассОМ) = "ПЛАНВИДОВРАСЧЕТА" Тогда
		Менеджер = ПланыВидовРасчета;
		
	ИначеЕсли ВРег(КлассОМ) = "РЕГИСТРСВЕДЕНИЙ" Тогда
		Менеджер = РегистрыСведений;
		
	ИначеЕсли ВРег(КлассОМ) = "РЕГИСТРНАКОПЛЕНИЯ" Тогда
		Менеджер = РегистрыНакопления;
		
	ИначеЕсли ВРег(КлассОМ) = "РЕГИСТРБУХГАЛТЕРИИ" Тогда
		Менеджер = РегистрыБухгалтерии;
		
	ИначеЕсли ВРег(КлассОМ) = "РЕГИСТРРАСЧЕТА" Тогда
		Если ЧастиИмени.Количество() = 2 Тогда
			// Регистр расчета
			Менеджер = РегистрыРасчета;
		Иначе
			КлассПодчиненногоОМ = ЧастиИмени[2];
			ИмяПодчиненногоОМ = ЧастиИмени[3];
			Если ВРег(КлассПодчиненногоОМ) = "ПЕРЕРАСЧЕТ" Тогда
				// Перерасчет
				Попытка
					Менеджер = РегистрыРасчета[ИмяОМ].Перерасчеты;
					ИмяОм = ИмяПодчиненногоОМ;
				Исключение
					Менеджер = Неопределено;
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;
		
	ИначеЕсли ВРег(КлассОМ) = "БИЗНЕСПРОЦЕСС" Тогда
		Менеджер = БизнесПроцессы;
		
	ИначеЕсли ВРег(КлассОМ) = "ЗАДАЧА" Тогда
		Менеджер = Задачи;
		
	ИначеЕсли ВРег(КлассОМ) = "КОНСТАНТА" Тогда
		Менеджер = Константы;
		
	ИначеЕсли ВРег(КлассОМ) = "ПОСЛЕДОВАТЕЛЬНОСТЬ" Тогда
		Менеджер = Последовательности;
	КонецЕсли;
	
	Если Менеджер <> Неопределено Тогда
		Попытка
			Возврат Менеджер[ИмяОМ];
		Исключение
			Менеджер = Неопределено;
		КонецПопытки;
	КонецЕсли;
	
	ВызватьИсключение СтрШаблон(НСтр("ru = 'Неизвестный тип объекта метаданных ""%1""'"), ПолноеИмя);
	
КонецФункции
