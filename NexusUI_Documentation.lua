--[[
    NEXUS UI LIBRARY - DOCUMENTATION
    ================================
    
    Современная, оптимизированная и полностью кастомизируемая UI библиотека для Roblox
    
    ОСНОВНЫЕ ВОЗМОЖНОСТИ:
    - Плавные анимации с физикой пружин
    - Полностью кастомизируемые темы
    - Оптимизированная производительность с пулом объектов
    - Современный дизайн с эффектами стекла
    - Адаптивная система макетов
    - Встроенные функции доступности
    
    БЫСТРЫЙ СТАРТ:
    ==============
    
    local NexusUI = loadstring(game:HttpGet("path/to/NexusUI.lua"))()
    
    -- Создание окна
    local window = NexusUI.new({
        Title = "My Application",
        Size = UDim2.fromOffset(600, 400),
        Theme = {
            Primary = Color3.fromRGB(99, 102, 241),
            Background = Color3.fromRGB(15, 15, 15)
        }
    })
    
    -- Создание вкладки
    local tab = window:CreateTab({
        Name = "Main",
        Icon = "rbxassetid://123456789"
    })
    
    -- Создание секции
    local section = tab:CreateSection({
        Name = "Controls",
        Description = "Basic controls for the application"
    })
    
    -- Добавление элементов
    section:Button({
        Name = "TestButton",
        Text = "Click Me!"
    }, function()
        print("Button clicked!")
    end)
    
    ПОЛНАЯ ДОКУМЕНТАЦИЯ:
    ===================
]]

local Documentation = {}

--[[
    СОЗДАНИЕ ОКНА
    =============
    
    NexusUI.new(config)
    
    Параметры config:
    - Title: string - Заголовок окна (по умолчанию: "Nexus UI")
    - Size: UDim2 - Размер окна (по умолчанию: UDim2.fromOffset(600, 400))
    - MinSize: UDim2 - Минимальный размер (по умолчанию: UDim2.fromOffset(400, 300))
    - Resizable: boolean - Возможность изменения размера (по умолчанию: true)
    - Draggable: boolean - Возможность перетаскивания (по умолчанию: true)
    - CloseButton: boolean - Показать кнопку закрытия (по умолчанию: true)
    - MinimizeButton: boolean - Показать кнопку сворачивания (по умолчанию: true)
    - Theme: table - Пользовательская тема (см. раздел ТЕМЫ)
    
    Пример:
    local window = NexusUI.new({
        Title = "Advanced Settings",
        Size = UDim2.fromOffset(800, 600),
        Resizable = true,
        Theme = {
            Primary = Color3.fromRGB(139, 92, 246),
            Secondary = Color3.fromRGB(99, 102, 241)
        }
    })
]]

--[[
    МЕТОДЫ ОКНА
    ===========
    
    window:CreateTab(config) - Создать новую вкладку
    window:SetActiveTab(tab) - Установить активную вкладку
    window:ToggleMinimize() - Переключить сворачивание
    window:Close() - Закрыть окно
    window:SetVisible(visible) - Показать/скрыть окно
    window:Destroy() - Уничтожить окно и освободить ресурсы
]]

--[[
    СОЗДАНИЕ ВКЛАДКИ
    ================
    
    window:CreateTab(config)
    
    Параметры config:
    - Name: string - Название вкладки (обязательно)
    - Icon: string - ID иконки (опционально)
    - Closable: boolean - Возможность закрытия вкладки (по умолчанию: false)
    
    Пример:
    local mainTab = window:CreateTab({
        Name = "Main",
        Icon = "rbxassetid://123456789"
    })
    
    local settingsTab = window:CreateTab({
        Name = "Settings",
        Closable = true
    })
]]

--[[
    МЕТОДЫ ВКЛАДКИ
    ==============
    
    tab:CreateSection(config) - Создать новую секцию
    tab:SetActive(active) - Установить активность вкладки
    tab:SetVisible(visible) - Показать/скрыть вкладку
    tab:Destroy() - Уничтожить вкладку
]]

--[[
    СОЗДАНИЕ СЕКЦИИ
    ===============
    
    tab:CreateSection(config)
    
    Параметры config:
    - Name: string - Название секции (обязательно)
    - Description: string - Описание секции (опционально)
    
    Пример:
    local controlsSection = tab:CreateSection({
        Name = "Controls",
        Description = "Basic application controls"
    })
    
    local advancedSection = tab:CreateSection({
        Name = "Advanced Settings"
    })
]]

--[[
    ЭЛЕМЕНТЫ ИНТЕРФЕЙСА
    ===================
    
    1. КНОПКА
    ---------
    section:Button(config, callback)
    
    Параметры config:
    - Name: string - Уникальное имя элемента
    - Text: string - Текст на кнопке
    
    Пример:
    section:Button({
        Name = "SaveButton",
        Text = "Save Settings"
    }, function()
        print("Settings saved!")
    end)
    
    2. ПЕРЕКЛЮЧАТЕЛЬ (TOGGLE)
    -------------------------
    section:Toggle(config, callback)
    
    Параметры config:
    - Name: string - Уникальное имя элемента
    - Text: string - Текст рядом с переключателем
    - Default: boolean - Начальное состояние (по умолчанию: false)
    
    Пример:
    local toggle = section:Toggle({
        Name = "AutoSave",
        Text = "Enable Auto Save",
        Default = true
    }, function(enabled)
        print("Auto save:", enabled)
    end)
    
    -- Методы:
    toggle.getValue() - Получить текущее значение
    toggle.setValue(value) - Установить значение
    
    3. СЛАЙДЕР
    ----------
    section:Slider(config, callback)
    
    Параметры config:
    - Name: string - Уникальное имя элемента
    - Text: string - Текст рядом со слайдером
    - Min: number - Минимальное значение (по умолчанию: 0)
    - Max: number - Максимальное значение (по умолчанию: 100)
    - Default: number - Начальное значение
    
    Пример:
    local slider = section:Slider({
        Name = "Volume",
        Text = "Master Volume",
        Min = 0,
        Max = 100,
        Default = 50
    }, function(value)
        print("Volume set to:", value)
    end)
    
    -- Методы:
    slider.getValue() - Получить текущее значение
    slider.setValue(value) - Установить значение
    
    4. ПОЛЕ ВВОДА
    -------------
    section:Input(config, callback)
    
    Параметры config:
    - Name: string - Уникальное имя элемента
    - Text: string - Заголовок поля
    - Placeholder: string - Текст-подсказка
    - Default: string - Начальное значение
    
    Пример:
    local input = section:Input({
        Name = "Username",
        Text = "Player Name",
        Placeholder = "Enter your name...",
        Default = "Player1"
    }, function(text)
        print("Name changed to:", text)
    end)
    
    -- Методы:
    input.getValue() - Получить текущий текст
    input.setValue(text) - Установить текст
    
    5. ВЫПАДАЮЩИЙ СПИСОК
    --------------------
    section:Dropdown(config, callback)
    
    Параметры config:
    - Name: string - Уникальное имя элемента
    - Text: string - Заголовок списка
    - Options: table - Массив вариантов
    - Default: string - Выбранный по умолчанию вариант
    
    Пример:
    local dropdown = section:Dropdown({
        Name = "Quality",
        Text = "Graphics Quality",
        Options = {"Low", "Medium", "High", "Ultra"},
        Default = "Medium"
    }, function(selected)
        print("Quality set to:", selected)
    end)
    
    -- Методы:
    dropdown.getValue() - Получить выбранное значение
    dropdown.setValue(value) - Установить выбранное значение
]]

--[[
    СИСТЕМА ТЕМ
    ===========
    
    Nexus UI поддерживает полную кастомизацию внешнего вида через систему тем.
    
    СТРУКТУРА ТЕМЫ:
    
    local customTheme = {
        -- Основные цвета
        Primary = Color3.fromRGB(99, 102, 241),      -- Основной цвет
        Secondary = Color3.fromRGB(139, 92, 246),    -- Вторичный цвет
        Success = Color3.fromRGB(34, 197, 94),       -- Цвет успеха
        Warning = Color3.fromRGB(251, 191, 36),      -- Цвет предупреждения
        Error = Color3.fromRGB(239, 68, 68),         -- Цвет ошибки
        
        -- Цвета фона
        Background = Color3.fromRGB(15, 15, 15),     -- Основной фон
        Surface = Color3.fromRGB(25, 25, 25),        -- Поверхности
        SurfaceVariant = Color3.fromRGB(35, 35, 35), -- Вариант поверхности
        
        -- Цвета текста
        TextPrimary = Color3.fromRGB(255, 255, 255),   -- Основной текст
        TextSecondary = Color3.fromRGB(156, 163, 175), -- Вторичный текст
        TextMuted = Color3.fromRGB(107, 114, 128),     -- Приглушенный текст
        
        -- Цвета границ
        Border = Color3.fromRGB(55, 55, 55),         -- Обычные границы
        BorderHover = Color3.fromRGB(75, 75, 75),    -- Границы при наведении
        
        -- Прозрачность
        GlassTransparency = 0.1,    -- Прозрачность стеклянного эффекта
        HoverTransparency = 0.05,   -- Прозрачность при наведении
        
        -- Радиус углов
        CornerRadius = UDim.new(0, 12),      -- Основной радиус
        SmallCornerRadius = UDim.new(0, 8),  -- Малый радиус
        
        -- Тени
        ShadowColor = Color3.fromRGB(0, 0, 0),  -- Цвет тени
        ShadowTransparency = 0.5,               -- Прозрачность тени
        
        -- Шрифты
        FontPrimary = Enum.Font.GothamBold,   -- Основной шрифт
        FontSecondary = Enum.Font.Gotham,     -- Вторичный шрифт
        FontMono = Enum.Font.RobotoMono,      -- Моноширинный шрифт
        
        -- Размеры текста
        TextSizeLarge = 18,   -- Крупный текст
        TextSizeMedium = 14,  -- Средний текст
        TextSizeSmall = 12,   -- Мелкий текст
    }
    
    ПРИМЕНЕНИЕ ТЕМЫ:
    
    -- При создании окна
    local window = NexusUI.new({
        Title = "My App",
        Theme = customTheme
    })
    
    -- Изменение темы во время выполнения
    window.theme:UpdateTheme({
        Primary = Color3.fromRGB(255, 100, 100),
        Background = Color3.fromRGB(20, 20, 20)
    })
    
    ГОТОВЫЕ ТЕМЫ:
    
    -- Темная тема (по умолчанию)
    local darkTheme = {
        Primary = Color3.fromRGB(99, 102, 241),
        Background = Color3.fromRGB(15, 15, 15),
        Surface = Color3.fromRGB(25, 25, 25),
        TextPrimary = Color3.fromRGB(255, 255, 255)
    }
    
    -- Светлая тема
    local lightTheme = {
        Primary = Color3.fromRGB(99, 102, 241),
        Background = Color3.fromRGB(255, 255, 255),
        Surface = Color3.fromRGB(245, 245, 245),
        SurfaceVariant = Color3.fromRGB(235, 235, 235),
        TextPrimary = Color3.fromRGB(0, 0, 0),
        TextSecondary = Color3.fromRGB(100, 100, 100),
        Border = Color3.fromRGB(200, 200, 200)
    }
    
    -- Неоновая тема
    local neonTheme = {
        Primary = Color3.fromRGB(0, 255, 255),
        Secondary = Color3.fromRGB(255, 0, 255),
        Background = Color3.fromRGB(5, 5, 15),
        Surface = Color3.fromRGB(10, 10, 25),
        TextPrimary = Color3.fromRGB(0, 255, 255),
        GlassTransparency = 0.05
    }
]]

--[[
    УВЕДОМЛЕНИЯ
    ===========
    
    NexusUI.CreateNotification(config)
    
    Параметры config:
    - Title: string - Заголовок уведомления
    - Description: string - Текст уведомления
    - Duration: number - Время показа в секундах (по умолчанию: 5)
    
    Пример:
    NexusUI.CreateNotification({
        Title = "Success!",
        Description = "Settings have been saved successfully.",
        Duration = 3
    })
]]

--[[
    ОПТИМИЗАЦИЯ И ПРОИЗВОДИТЕЛЬНОСТЬ
    ================================
    
    Nexus UI включает несколько оптимизаций для максимальной производительности:
    
    1. ПУЛ ОБЪЕКТОВ
    ---------------
    Библиотека использует пул объектов для переиспользования GUI элементов,
    что значительно снижает нагрузку на сборщик мусора.
    
    2. ПЛАВНЫЕ АНИМАЦИИ
    -------------------
    Все анимации оптимизированы и используют TweenService с правильными
    настройками easing для максимальной плавности.
    
    3. ЛЕНИВАЯ ЗАГРУЗКА
    -------------------
    Элементы создаются только при необходимости, что ускоряет
    инициализацию интерфейса.
    
    4. УПРАВЛЕНИЕ ПАМЯТЬЮ
    ---------------------
    Все соединения (connections) автоматически отключаются при
    уничтожении элементов, предотвращая утечки памяти.
    
    РЕКОМЕНДАЦИИ ПО ИСПОЛЬЗОВАНИЮ:
    
    - Всегда вызывайте :Destroy() для окон, которые больше не нужны
    - Используйте :SetVisible(false) вместо создания новых элементов
    - Группируйте связанные элементы в одну секцию
    - Избегайте создания слишком много элементов одновременно
]]

--[[
    ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ
    =====================
    
    ПРОСТОЕ ПРИЛОЖЕНИЕ:
    
    local NexusUI = loadstring(game:HttpGet("path/to/NexusUI.lua"))()
    
    local window = NexusUI.new({
        Title = "Simple App",
        Size = UDim2.fromOffset(500, 350)
    })
    
    local tab = window:CreateTab({Name = "Main"})
    local section = tab:CreateSection({Name = "Controls"})
    
    section:Button({Text = "Hello World"}, function()
        print("Hello, World!")
    end)
    
    section:Toggle({Text = "Enable Feature", Default = false}, function(enabled)
        print("Feature enabled:", enabled)
    end)
    
    ПРОДВИНУТОЕ ПРИЛОЖЕНИЕ:
    
    local NexusUI = loadstring(game:HttpGet("path/to/NexusUI.lua"))()
    
    -- Пользовательская тема
    local customTheme = {
        Primary = Color3.fromRGB(139, 92, 246),
        Secondary = Color3.fromRGB(99, 102, 241),
        Background = Color3.fromRGB(10, 10, 15)
    }
    
    local window = NexusUI.new({
        Title = "Advanced Settings",
        Size = UDim2.fromOffset(700, 500),
        Theme = customTheme
    })
    
    -- Основная вкладка
    local mainTab = window:CreateTab({Name = "Main"})
    local generalSection = mainTab:CreateSection({
        Name = "General Settings",
        Description = "Basic application settings"
    })
    
    local playerName = generalSection:Input({
        Name = "PlayerName",
        Text = "Player Name",
        Placeholder = "Enter your name...",
        Default = game.Players.LocalPlayer.Name
    }, function(name)
        print("Player name set to:", name)
    end)
    
    local volume = generalSection:Slider({
        Name = "Volume",
        Text = "Master Volume",
        Min = 0,
        Max = 100,
        Default = 75
    }, function(value)
        print("Volume:", value .. "%")
    end)
    
    local quality = generalSection:Dropdown({
        Name = "Quality",
        Text = "Graphics Quality",
        Options = {"Low", "Medium", "High", "Ultra"},
        Default = "High"
    }, function(selected)
        print("Quality set to:", selected)
    end)
    
    -- Вкладка настроек
    local settingsTab = window:CreateTab({Name = "Settings"})
    local advancedSection = settingsTab:CreateSection({
        Name = "Advanced Options"
    })
    
    advancedSection:Toggle({
        Name = "DebugMode",
        Text = "Enable Debug Mode",
        Default = false
    }, function(enabled)
        if enabled then
            NexusUI.CreateNotification({
                Title = "Debug Mode",
                Description = "Debug mode has been enabled.",
                Duration = 3
            })
        end
    end)
    
    advancedSection:Button({
        Name = "ResetSettings",
        Text = "Reset to Defaults"
    }, function()
        playerName.setValue(game.Players.LocalPlayer.Name)
        volume.setValue(75)
        quality.setValue("High")
        
        NexusUI.CreateNotification({
            Title = "Settings Reset",
            Description = "All settings have been reset to defaults.",
            Duration = 2
        })
    end)
]]

--[[
    ЧАСТО ЗАДАВАЕМЫЕ ВОПРОСЫ
    ========================
    
    В: Как изменить тему после создания окна?
    О: Используйте window.theme:UpdateTheme({новые_параметры})
    
    В: Можно ли создать несколько окон?
    О: Да, каждый вызов NexusUI.new() создает независимое окно
    
    В: Как сохранить настройки между сессиями?
    О: Используйте DataStoreService или файлы для сохранения значений элементов
    
    В: Поддерживается ли мобильная версия?
    О: Да, интерфейс адаптируется под разные размеры экрана
    
    В: Как добавить собственные элементы?
    О: Расширьте класс Section, добавив новые методы для ваших элементов
    
    В: Влияет ли библиотека на производительность игры?
    О: Минимально, благодаря оптимизациям и пулу объектов
]]

return Documentation
