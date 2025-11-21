# Техническая справка (Technical Reference)

Этот раздел содержит техническую информацию по установке, настройке и решению проблем.

---

## 1. Установка (Installation)

1.  **Копирование**: Поместите папку `Avatar_Studio_QS` в директорию `Plugins` вашего проекта (создайте её, если нет).
2.  **Активация**: Запустите проект, перейдите в `Edit -> Plugins` и убедитесь, что плагин **Avatar Studio QS** включен.
3.  **Перезапуск**: Перезапустите редактор.

---

## 2. Настройка MFA (MFA Setup)

Для работы автоматического липсинка требуется **Montreal Forced Aligner**.

1.  **Скачивание**: Скачайте MFA с официального сайта.
2.  **Путь**: Укажите путь к исполняемому файлу MFA в настройках проекта:
    *   `Project Settings -> Avatar Studio QS -> MFA Path`.
3.  **Словари**: Убедитесь, что у вас скачаны словари для нужных языков (English, Russian). Плагин попытается найти их автоматически в папке `MFA/pretrained_models`.

---

## 3. Структура файлов (File Structure)

Плагин хранит данные в папке `Content/QuestSystem`:
*   `/Quests` — Ассеты квестов.
*   `/Dialogues` — Ассеты диалогов.
*   `/NPCs` — Таблицы NPC.
*   `/Voices` — Профили голоса и аудио.
*   `/Spawners` — Конфигурации спавнеров.

---

## 4. Решение проблем (Troubleshooting)

### Липсинк не генерируется
*   **Проверьте путь к MFA**: Убедитесь, что путь в настройках верен.
*   **Проверьте аудио**: Файл должен быть в формате `.wav` (16-bit, 44.1kHz рекомендуется).
*   **Проверьте текст**: Субтитры должны соответствовать аудио. Сильные расхождения могут сбить алгоритм.

### NPC не спавнится
*   **Проверьте Spawner**: Убедитесь, что в спавнере выбран правильный NPC ID.
*   **Проверьте NavMesh**: Для спавна на земле требуется NavMesh. Если его нет, NPC может не появиться.

---

## 5. Interaction System (Система взаимодействия)

**Interaction System** — готовая система для взаимодействия игрока с объектами в мире (двери, сундуки, NPC).

### Компоненты:

#### A. `UAS_IS_ScannerComponent` — Сканер
*   **Назначение**: Трассировка луча от камеры для поиска интерактивных объектов
*   **Как работает**: Каждый кадр проверяет, на что смотрит игрок
*   **Настройки**:
    *   **Scan Distance** — Дистанция трассировки (по умолчанию 500 см)
    *   **Scan Frequency** — Частота сканирования (каждый кадр или реже)

#### B. `UAS_IS_PlayerInteractionComponent` — Менеджер взаимодействия
*   **Назначение**: Управляет всей логикой взаимодействия
*   **Функции**:
    *   `AttemptInteraction()` — Попытка взаимодействия (вызывается при нажатии клавиши)
    *   Автоматическое создание UI-виджетов (прицел, подсказка)
    *   Подписка на события сканера

#### C. `UAS_IS_CrosshairWidget` — Виджет прицела
*   **Назначение**: Отображение прицела в центре экрана
*   **Возможности**:
    *   Изменение цвета при наведении на интерактивный объект
    *   Изменение формы (точка, крест, круг)
    *   Анимации (пульсация, расширение)

#### D. `UAS_IS_PromptWidget` — Виджет подсказки
*   **Назначение**: Отображение подсказки "Нажмите E для взаимодействия"
*   **Возможности**:
    *   Автоматическое обновление текста (зависит от объекта)
    *   Позиционирование относительно объекта или центра экрана
    *   Анимации появления/исчезновения

#### E. `UAS_IS_InterComponent` — Компонент на интерактивных объектах
*   **Назначение**: Делает объект интерактивным
*   **Настройки**:
    *   **Interaction Text** — Текст подсказки ("Открыть дверь", "Взять предмет")
    *   **Interaction Tag** — Тег для фильтрации (опционально)
    *   **bIsEnabled** — Включен ли объект для взаимодействия

#### F. `UAS_IS_PointComponent` — Точка для UI-подсказок
*   **Назначение**: Определяет точку, где должна отображаться подсказка
*   **Использование**: Размещается на объекте (например, на ручке двери)

### Workflow:

1.  **Добавьте компоненты на Player Character**:
    *   `UAS_IS_ScannerComponent`
    *   `UAS_IS_PlayerInteractionComponent`
2.  **Добавьте компоненты на интерактивный объект**:
    *   `UAS_IS_InterComponent` (настройте текст подсказки)
    *   `UAS_IS_PointComponent` (опционально, для позиционирования UI)
3.  **Реализуйте интерфейс `IAS_IS_HandlerInterface`** на объекте:
    *   `OnInteractionStarted()` — Вызывается при взаимодействии
    *   `OnInteractionEnded()` — Вызывается при завершении взаимодействия
4.  **Настройте UI-виджеты** (прицел, подсказка) в настройках `UAS_IS_PlayerInteractionComponent`

### Пример (Blueprint):

```cpp
// На интерактивном объекте (например, двери)
void ADoor::OnInteractionStarted_Implementation(AActor* Interactor)
{
    // Открыть дверь
    OpenDoor();
}
```

---

## 6. Player Character (`AAS_PlayerCharacter`)

**AAS_PlayerCharacter** — готовый класс Player Character с полной интеграцией всех систем плагина.

### Возможности:

#### A. Locomotion (Передвижение)
*   **3 режима**: Ходьба / Бег / Спринт
*   **Автоматическое переключение**:
    *   По умолчанию — Бег
    *   Клавиша Toggle Run — переключение между Ходьбой и Бегом
    *   Клавиша Sprint (зажать) — Спринт
*   **Настройки скорости**:
    *   `WalkSpeed = 200`
    *   `RunSpeed = 600`
    *   `SprintSpeed = 900`

#### B. Camera System (Система камеры)
*   **Плавный зум** — От 1-го лица до 3-го лица (колесо мыши)
*   **Автоматическое переключение** — При зуме ближе `MinZoomLength` (50 см) камера переключается в режим от 1-го лица
*   **Настройки**:
    *   `MinZoomLength = 50` — Минимальная дистанция (1-е лицо)
    *   `MaxZoomLength = 800` — Максимальная дистанция (3-е лицо)
    *   `ZoomStep = 40` — Шаг зума
    *   `ThirdPersonCameraSocketOffsetY = 40` — Смещение камеры (через плечо)
    *   `ThirdPersonCameraSocketOffsetZ = 60` — Высота камеры

#### C. Interaction Integration (Интеграция взаимодействия)
*   **Встроенные компоненты**:
    *   `UAS_IS_ScannerComponent` — Сканер интерактивных объектов
    *   `UAS_IS_PlayerInteractionComponent` — Менеджер взаимодействия
*   **Готовая логика**: Нажатие клавиши "E" автоматически вызывает взаимодействие

#### D. Dialogue Integration (Интеграция диалогов)
*   **Встроенные компоненты**:
    *   `UBPC_DialogueExecutor` — Исполнитель диалогов
    *   `UAudioComponent` — Аудио для озвучки
*   **Автоматическая обработка**: Диалоги автоматически воспроизводятся с липсинком

#### E. Gaze Integration (Интеграция взгляда)
*   **Встроенный компонент**: `UAS_QS_LookAtControllerComponent`
*   **Режимы**:
    *   **Limited Mode** — Ненавязчивые движения головы (при активном управлении)
    *   **Full Mode** — Полный блуждающий взгляд (при бездействии)
    *   **Combat Mode** — Фокусировка на враге
    *   **Interact Mode** — Фокусировка на интерактивном объекте

### Использование:

1.  **Создайте Blueprint** на основе `AAS_PlayerCharacter`
2.  **Настройте скелетный меш** и анимации
3.  **Настройте Input Bindings** в Project Settings:
    *   Move (Axis)
    *   Look (Axis)
    *   Jump (Action)
    *   Interact (Action)
    *   ToggleRun (Action)
    *   Sprint (Action)
4.  **Настройте UI-виджеты** для прицела и подсказок

---

## 7. Save System (Система сохранения)

**Save System** — автоматическая система сохранения состояния квестов, репутации и инвентаря.

### Класс: `UAvatar_Studio_QS_RT_SaveGame`

Наследуется от `USaveGame` и содержит:
*   **Quest Progress** — Состояние всех квестов и стадий
*   **Faction Reputation** — Репутация со всеми фракциями
*   **Inventory** — Инвентарь игрока (если используется)
*   **World State** — Состояние мира (открытые двери, собранные предметы)

### Автоматическое сохранение:

Quest Manager и Faction Manager автоматически сохраняют свое состояние при изменениях:
*   Квест активирован → Сохранение
*   Стадия завершена → Сохранение
*   Репутация изменена → Сохранение

### Ручное сохранение/загрузка:

#### Сохранение:
```cpp
// Создать объект сохранения
UAvatar_Studio_QS_RT_SaveGame* SaveGameObject = Cast<UAvatar_Studio_QS_RT_SaveGame>(
    UGameplayStatics::CreateSaveGameObject(UAvatar_Studio_QS_RT_SaveGame::StaticClass())
);

// Заполнить данными из Quest Manager
UQuestManager* QM = GetGameInstance()->GetSubsystem<UQuestManager>();
QM->PopulateSaveData(SaveGameObject);

// Заполнить данными из Faction Manager
UAS_FM* FM = GetGameInstance()->GetSubsystem<UAS_FM>();
// FM->PopulateSaveData(SaveGameObject); // Если реализовано

// Сохранить в слот
UGameplayStatics::SaveGameToSlot(SaveGameObject, "SaveSlot_01", 0);
```

#### Загрузка:
```cpp
// Загрузить из слота
UAvatar_Studio_QS_RT_SaveGame* LoadedGame = Cast<UAvatar_Studio_QS_RT_SaveGame>(
    UGameplayStatics::LoadGameFromSlot("SaveSlot_01", 0)
);

if (LoadedGame)
{
    // Применить данные к Quest Manager
    UQuestManager* QM = GetGameInstance()->GetSubsystem<UQuestManager>();
    QM->ApplyLoadedData(LoadedGame);
    
    // Применить данные к Faction Manager
    // UAS_FM* FM = GetGameInstance()->GetSubsystem<UAS_FM>();
    // FM->ApplyLoadedData(LoadedGame); // Если реализовано
}
```

### Важные замечания:

1.  **Сохранение происходит в слоты** — Вы можете иметь несколько сохранений ("SaveSlot_01", "SaveSlot_02", и т.д.)
2.  **Автоматическое сохранение** — Quest Manager автоматически сохраняет прогресс при изменениях (опционально)
3.  **Сериализация** — Все данные сериализуются в бинарный формат Unreal Engine

---

## 8. Runtime Systems (Менеджеры)

Для подробной информации о runtime-системах (Quest Manager, Dialogue Manager, Faction Manager, Spawn Manager) см. [Runtime Systems](runtime_systems.md).

---

[Вернуться на главную](index.md)
