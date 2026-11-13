-- Player-facing text. English is complete, and it fills any gap.
-- GetLocale() is one of: deDE, enGB, enUS, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW.
-- enGB shares the enUS lines. esES and esMX share one table until a wording needs to split.
-- To add a language, copy the deDE table, translate the values, and set it in `locales`.
-- Slash commands stay /ftc. Debug lines stay in FlightTimerClassic.lua, in English.
-- Place names are already in the client language. Do not translate them here.
local _, ns = ...

local enUS = {
    -- Tooltip. The addon name matches the title in the addon list.
    Title = "Flight Timer Classic",
    EstimatedTime = "Estimated time:",
    RecordedTime = "Recorded time:",
    FlyingFrom = "Flying from:",
    FlyingTo = "Flying to:",
    PasteHint = "Shift-click while typing to paste your arrival.",

    -- Pasted into chat. Overdue/Arriving: place, then time. NoPlace: time only.
    ArrivalOverdue = "Arrival in %s %s overdue, landing any second now",
    ArrivalOverdueNoPlace = "Arrival %s overdue, landing any second now",
    Arriving = "Arriving in %s in %s",
    ArrivingNoPlace = "Arriving in %s",

    -- After a flight. %s values are already colored: origin, destination, duration.
    -- Correction adds the previous duration as the fourth %s.
    NewData = "New data: %s to %s took %s.",
    Correction = "Correction: %s to %s took %s (was %s).",
    Arrived = "Arrived at %s after %s.",
    FlightCancelled = "Flight cancelled.",
    -- Origin, then destination.
    UnknownFlight = "Unknown flightpath. Measuring duration from %s to %s.",

    -- %s is "no map frame", or a frame name left in English for bug reports.
    PinsUnavailable = "Flight map pins unavailable (%s).",
    NoMapFrame = "no map frame",

    -- %s is the slash command, already colored. The command words stay English.
    DebugOn = "Debug on. Type %s to turn it off.",
    DebugOff = "Debug off. Type %s to turn it on.",
    -- Login line ("Ready") and the duration lines after landing.
    MuteLoginOn = "Login message on. Type %s to hide it.",
    MuteLoginOff = "Login message off. Type %s to show it.",
    MuteReportOn = "Flight report on. Type %s to hide it.",
    MuteReportOff = "Flight report off. Type %s to show it.",
    TimerShown = "Timer shown for positioning. Type %s to hide it.",
    TimerAlreadyShown = "Timer already shown. Type %s to hide it.",
    TimerHidden = "Timer hidden. Type %s to show it.",
    TimerAlreadyHidden = "Timer already hidden. Type %s to show it.",
    HelpShow = "%s – Show the timer for positioning.",
    HelpHide = "%s – Hide the timer.",
    HelpMute = "%s – Show which messages are currently muted.",
    HelpMuteLogin = "%s – Mute or show the login message.",
    HelpMuteReport = "%s – Mute or show the flight report.",
    HelpMuteAll = "%s – Mute the login message and the flight report.",
    HelpMuteNone = "%s – Show the login message and the flight report.",
    HelpDebug = "%s – Turn debug output on or off.",
    HelpHelp = "%s – Show this help.",
    HelpPaste = "Shift-click the timer while typing to paste your arrival.",
    -- %s is the typed token, in quotes.
    UnknownCommand = "unknown command: %s",
    Ready = "Ready. Type %s for all commands.",
    NoData = "No flight durations included. Type %s for all commands."
}

-- The client already translated these ("3m 12s"). One value serves every language.
enUS.TimeMinSec = gsub(MINUTE_ONELETTER_ABBR, "%s", "") .. " " .. gsub(SECOND_ONELETTER_ABBR, "%s", "")
enUS.TimeSec = gsub(SECOND_ONELETTER_ABBR, "%s", "")

local deDE = {
    EstimatedTime = "Geschätzte Flugzeit:",
    RecordedTime = "Erfasste Flugzeit:",
    FlyingFrom = "Flug von:",
    FlyingTo = "Flug nach:",
    PasteHint = "Umschalt-Klick, um die Ankunft im Chat einzufügen.",

    ArrivalOverdue = "Ankunft in %s um %s überfällig, Landung steht kurz bevor.",
    ArrivalOverdueNoPlace = "Ankunft um %s überfällig, Landung steht kurz bevor.",
    Arriving = "Ankunft in %s in %s",
    ArrivingNoPlace = "Ankunft in %s",

    NewData = "Neue Daten: %s nach %s hat %s gedauert.",
    Correction = "Korrektur: %s nach %s hat %s gedauert (war %s).",
    Arrived = "Angekommen in %s nach %s.",
    FlightCancelled = "Flug abgebrochen.",
    UnknownFlight = "Unbekannter Flugpfad. Die Dauer von %s nach %s wird gemessen.",

    PinsUnavailable = "Punkte auf der Flugkarte nicht verfügbar (%s).",
    NoMapFrame = "kein Kartenfenster",

    DebugOn = "Debug an. Zum Ausschalten %s eingeben.",
    DebugOff = "Debug aus. Zum Einschalten %s eingeben.",
    MuteLoginOn = "Login-Nachricht an. Zum Ausblenden %s eingeben.",
    MuteLoginOff = "Login-Nachricht aus. Zum Einblenden %s eingeben.",
    MuteReportOn = "Flugbericht an. Zum Ausblenden %s eingeben.",
    MuteReportOff = "Flugbericht aus. Zum Einblenden %s eingeben.",
    TimerShown = "Timer zum Positionieren eingeblendet. Zum Ausblenden %s eingeben.",
    TimerAlreadyShown = "Timer ist bereits eingeblendet. Zum Ausblenden %s eingeben.",
    TimerHidden = "Timer ausgeblendet. Zum Einblenden %s eingeben.",
    TimerAlreadyHidden = "Timer ist bereits ausgeblendet. Zum Einblenden %s eingeben.",
    HelpShow = "%s – Timer zum Positionieren einblenden.",
    HelpHide = "%s – Timer ausblenden.",
    HelpMute = "%s – Anzeigen, welche Nachrichten derzeit stummgeschaltet sind.",
    HelpMuteLogin = "%s – Login-Nachricht ein- oder ausblenden.",
    HelpMuteReport = "%s – Flugbericht ein- oder ausblenden.",
    HelpMuteAll = "%s – Login-Nachricht und Flugbericht ausblenden.",
    HelpMuteNone = "%s – Login-Nachricht und Flugbericht einblenden.",
    HelpDebug = "%s – Debug-Ausgabe ein- oder ausschalten.",
    HelpHelp = "%s – Diese Hilfe anzeigen.",
    HelpPaste = "Umschalt-Klick auf den Timer, um die Ankunft im Chat einzufügen.",
    UnknownCommand = "Unbekannter Befehl: %s",
    Ready = "Bereit. %s zeigt alle Befehle.",
    NoData = "Keine Flugzeiten enthalten. %s zeigt alle Befehle."
}

-- European and Latin American Spanish share this until a line needs to differ.
local es = {
    EstimatedTime = "Tiempo estimado:",
    RecordedTime = "Tiempo registrado:",
    FlyingFrom = "Vuelo de:",
    FlyingTo = "Vuelo a:",
    PasteHint = "Mayús-clic mientras escribes para pegar tu llegada.",

    ArrivalOverdue = "Llegada a %s con %s de retraso; aterrizará en cualquier momento.",
    ArrivalOverdueNoPlace = "Llegada con %s de retraso; aterrizará en cualquier momento.",
    Arriving = "Llegando a %s en %s",
    ArrivingNoPlace = "Llegando en %s",

    NewData = "Datos nuevos: de %s a %s en %s.",
    Correction = "Corrección: de %s a %s en %s (antes %s).",
    Arrived = "Llegada a %s tras %s.",
    FlightCancelled = "Vuelo cancelado.",
    UnknownFlight = "Ruta de vuelo desconocida. Midiendo la duración de %s a %s.",

    PinsUnavailable = "Puntos del mapa de vuelo no disponibles (%s).",
    NoMapFrame = "sin marco de mapa",

    DebugOn = "Depuración activada. Escribe %s para desactivarla.",
    DebugOff = "Depuración desactivada. Escribe %s para activarla.",
    MuteLoginOn = "Mensaje de inicio de sesión activado. Escribe %s para ocultarlo.",
    MuteLoginOff = "Mensaje de inicio de sesión desactivado. Escribe %s para mostrarlo.",
    MuteReportOn = "Informe de vuelo activado. Escribe %s para ocultarlo.",
    MuteReportOff = "Informe de vuelo desactivado. Escribe %s para mostrarlo.",
    TimerShown = "Temporizador mostrado para colocarlo. Escribe %s para ocultarlo.",
    TimerAlreadyShown = "El temporizador ya está visible. Escribe %s para ocultarlo.",
    TimerHidden = "Temporizador oculto. Escribe %s para mostrarlo.",
    TimerAlreadyHidden = "El temporizador ya está oculto. Escribe %s para mostrarlo.",
    HelpShow = "%s – Mostrar el temporizador para colocarlo.",
    HelpHide = "%s – Ocultar el temporizador.",
    HelpMute = "%s – Mostrar qué mensajes están silenciados actualmente.",
    HelpMuteLogin = "%s – Silenciar o mostrar el mensaje de inicio de sesión.",
    HelpMuteReport = "%s – Silenciar o mostrar el informe de vuelo.",
    HelpMuteAll = "%s – Silenciar el mensaje de inicio de sesión y el informe de vuelo.",
    HelpMuteNone = "%s – Mostrar el mensaje de inicio de sesión y el informe de vuelo.",
    HelpDebug = "%s – Activar o desactivar la depuración.",
    HelpHelp = "%s – Mostrar esta ayuda.",
    HelpPaste = "Mayús-clic en el temporizador mientras escribes para pegar tu llegada.",
    UnknownCommand = "comando desconocido: %s",
    Ready = "Listo. Escribe %s para ver todos los comandos.",
    NoData = "No hay duraciones de vuelo incluidas. Escribe %s para ver todos los comandos."
}

local frFR = {
    EstimatedTime = "Temps estimé :",
    RecordedTime = "Temps enregistré :",
    FlyingFrom = "Vol depuis :",
    FlyingTo = "Vol vers :",
    PasteHint = "Maj-clic en écrivant pour coller votre arrivée.",

    ArrivalOverdue = "Arrivée à %s en retard de %s, atterrissage imminent",
    ArrivalOverdueNoPlace = "Arrivée en retard de %s, atterrissage imminent",
    Arriving = "Arrivée à %s dans %s",
    ArrivingNoPlace = "Arrivée dans %s",

    NewData = "Nouvelles données : de %s à %s a pris %s.",
    Correction = "Correction : de %s à %s a pris %s (au lieu de %s).",
    Arrived = "Arrivé à %s après %s.",
    FlightCancelled = "Vol annulé.",
    UnknownFlight = "Trajet inconnu. Mesure de la durée de %s à %s.",

    PinsUnavailable = "Repères de la carte de vol indisponibles (%s).",
    NoMapFrame = "aucun cadre de carte",

    DebugOn = "Débogage activé. Tapez %s pour le désactiver.",
    DebugOff = "Débogage désactivé. Tapez %s pour l'activer.",
    MuteLoginOn = "Message de connexion activé. Tapez %s pour le masquer.",
    MuteLoginOff = "Message de connexion désactivé. Tapez %s pour l'afficher.",
    MuteReportOn = "Rapport de vol activé. Tapez %s pour le masquer.",
    MuteReportOff = "Rapport de vol désactivé. Tapez %s pour l'afficher.",
    TimerShown = "Minuteur affiché pour le positionnement. Tapez %s pour le masquer.",
    TimerAlreadyShown = "Minuteur déjà affiché. Tapez %s pour le masquer.",
    TimerHidden = "Minuteur masqué. Tapez %s pour l'afficher.",
    TimerAlreadyHidden = "Minuteur déjà masqué. Tapez %s pour l'afficher.",
    HelpShow = "%s – Afficher le minuteur pour le positionnement.",
    HelpHide = "%s – Masquer le minuteur.",
    HelpMute = "%s – Afficher quels messages sont actuellement masqués.",
    HelpMuteLogin = "%s – Masquer ou afficher le message de connexion.",
    HelpMuteReport = "%s – Masquer ou afficher le rapport de vol.",
    HelpMuteAll = "%s – Masquer le message de connexion et le rapport de vol.",
    HelpMuteNone = "%s – Afficher le message de connexion et le rapport de vol.",
    HelpDebug = "%s – Activer ou désactiver la sortie de débogage.",
    HelpHelp = "%s – Afficher cette aide.",
    HelpPaste = "Maj-clic sur le minuteur en écrivant pour coller votre arrivée.",
    UnknownCommand = "Commande inconnue : %s",
    Ready = "Prêt. Tapez %s pour voir toutes les commandes.",
    NoData = "Aucune durée de vol incluse. Tapez %s pour voir toutes les commandes."
}

local ptBR = {
    EstimatedTime = "Tempo estimado:",
    RecordedTime = "Tempo registrado:",
    FlyingFrom = "Voando de:",
    FlyingTo = "Voando para:",
    PasteHint = "Shift-clique ao digitar para colar sua chegada.",

    ArrivalOverdue = "Chegada em %s com atraso de %s, pousando a qualquer momento",
    ArrivalOverdueNoPlace = "Chegada com atraso de %s, pousando a qualquer momento",
    Arriving = "Chegando em %s em %s",
    ArrivingNoPlace = "Chegando em %s",

    NewData = "Novos dados: de %s para %s levou %s.",
    Correction = "Correção: de %s para %s levou %s (antes %s).",
    Arrived = "Chegou a %s após %s.",
    FlightCancelled = "Voo cancelado.",
    UnknownFlight = "Rota de voo desconhecida. Medindo duração de %s para %s.",

    PinsUnavailable = "Marcadores do mapa de voo indisponíveis (%s).",
    NoMapFrame = "sem quadro de mapa",

    DebugOn = "Depuração ativada. Digite %s para desativar.",
    DebugOff = "Depuração desativada. Digite %s para ativar.",
    MuteLoginOn = "Mensagem de login ativada. Digite %s para ocultá-la.",
    MuteLoginOff = "Mensagem de login desativada. Digite %s para exibi-la.",
    MuteReportOn = "Relatório de voo ativado. Digite %s para ocultá-lo.",
    MuteReportOff = "Relatório de voo desativado. Digite %s para exibi-lo.",
    TimerShown = "Temporizador exibido para posicionamento. Digite %s para ocultar.",
    TimerAlreadyShown = "O temporizador já está visível. Digite %s para ocultar.",
    TimerHidden = "Temporizador oculto. Digite %s para exibir.",
    TimerAlreadyHidden = "O temporizador já está oculto. Digite %s para exibir.",
    HelpShow = "%s – Exibir o temporizador para posicionamento.",
    HelpHide = "%s – Ocultar o temporizador.",
    HelpMute = "%s – Mostrar quais mensagens estão silenciadas no momento.",
    HelpMuteLogin = "%s – Silenciar ou exibir a mensagem de login.",
    HelpMuteReport = "%s – Silenciar ou exibir o relatório de voo.",
    HelpMuteAll = "%s – Silenciar a mensagem de login e o relatório de voo.",
    HelpMuteNone = "%s – Exibir a mensagem de login e o relatório de voo.",
    HelpDebug = "%s – Ativar ou desativar saída de depuração.",
    HelpHelp = "%s – Exibir esta ajuda.",
    HelpPaste = "Shift-clique no temporizador ao digitar para colar sua chegada.",
    UnknownCommand = "Comando desconhecido: %s",
    Ready = "Pronto. Digite %s para ver todos os comandos.",
    NoData = "Nenhuma duração de voo incluída. Digite %s para ver todos os comandos."
}

local itIT = {
    EstimatedTime = "Tempo stimato:",
    RecordedTime = "Tempo registrato:",
    FlyingFrom = "In volo da:",
    FlyingTo = "In volo verso:",
    PasteHint = "Shift-clic mentre scrivi per incollare l'arrivo.",

    ArrivalOverdue = "Arrivo a %s in ritardo di %s, atterraggio imminente",
    ArrivalOverdueNoPlace = "Arrivo in ritardo di %s, atterraggio imminente",
    Arriving = "Arrivo a %s tra %s",
    ArrivingNoPlace = "Arrivo tra %s",

    NewData = "Nuovi dati: da %s a %s ha impiegato %s.",
    Correction = "Correzione: da %s a %s ha impiegato %s (prima %s).",
    Arrived = "Arrivato a %s dopo %s.",
    FlightCancelled = "Volo annullato.",
    UnknownFlight = "Rotta di volo sconosciuta. Misurazione della durata da %s a %s.",

    PinsUnavailable = "Indicatori sulla mappa di volo non disponibili (%s).",
    NoMapFrame = "nessun frame mappa",

    DebugOn = "Debug attivato. Digita %s per disattivarlo.",
    DebugOff = "Debug disattivato. Digita %s per attivarlo.",
    MuteLoginOn = "Messaggio di accesso attivato. Digita %s per nasconderlo.",
    MuteLoginOff = "Messaggio di accesso disattivato. Digita %s per mostrarlo.",
    MuteReportOn = "Rapporto di volo attivato. Digita %s per nasconderlo.",
    MuteReportOff = "Rapporto di volo disattivato. Digita %s per mostrarlo.",
    TimerShown = "Timer mostrato per il posizionamento. Digita %s per nasconderlo.",
    TimerAlreadyShown = "Timer già visibile. Digita %s per nasconderlo.",
    TimerHidden = "Timer nascosto. Digita %s per mostrarlo.",
    TimerAlreadyHidden = "Timer già nascosto. Digita %s per mostrarlo.",
    HelpShow = "%s – Mostra il timer per il posizionamento.",
    HelpHide = "%s – Nascondi il timer.",
    HelpMute = "%s – Mostra quali messaggi sono attualmente disattivati.",
    HelpMuteLogin = "%s – Disattiva o mostra il messaggio di accesso.",
    HelpMuteReport = "%s – Disattiva o mostra il rapporto di volo.",
    HelpMuteAll = "%s – Disattiva il messaggio di accesso e il rapporto di volo.",
    HelpMuteNone = "%s – Mostra il messaggio di accesso e il rapporto di volo.",
    HelpDebug = "%s – Attiva o disattiva l'output di debug.",
    HelpHelp = "%s – Mostra questa guida.",
    HelpPaste = "Shift-clic sul timer mentre scrivi per incollare l'arrivo.",
    UnknownCommand = "Comando sconosciuto: %s",
    Ready = "Pronto. Digita %s per mostrare tutti i comandi.",
    NoData = "Nessuna durata di volo inclusa. Digita %s per mostrare tutti i comandi."
}

local ruRU = {
    EstimatedTime = "Примерное время:",
    RecordedTime = "Записанное время:",
    FlyingFrom = "Полет из:",
    FlyingTo = "Полет в:",
    PasteHint = "Shift-клик при вводе текста, чтобы вставить время прибытия.",

    ArrivalOverdue = "Прибытие в %s просрочено на %s, посадка в любую секунду",
    ArrivalOverdueNoPlace = "Прибытие просрочено на %s, посадка в любую секунду",
    Arriving = "Прибытие в %s через %s",
    ArrivingNoPlace = "Прибытие через %s",

    NewData = "Новые данные: перелет из %s в %s занял %s.",
    Correction = "Исправление: перелет из %s в %s занял %s (было %s).",
    Arrived = "Прибыл в %s через %s.",
    FlightCancelled = "Полет отменен.",
    UnknownFlight = "Неизвестный маршрут. Измерение длительности полета из %s в %s.",

    PinsUnavailable = "Метки на карте полетов недоступны (%s).",
    NoMapFrame = "нет фрейма карты",

    DebugOn = "Отладка включена. Введите %s, чтобы отключить.",
    DebugOff = "Отладка отключена. Введите %s, чтобы включить.",
    MuteLoginOn = "Сообщение при входе включено. Введите %s, чтобы скрыть.",
    MuteLoginOff = "Сообщение при входе отключено. Введите %s, чтобы показать.",
    MuteReportOn = "Отчет о полете включен. Введите %s, чтобы скрыть.",
    MuteReportOff = "Отчет о полете отключен. Введите %s, чтобы показать.",
    TimerShown = "Таймер отображен для настройки позиции. Введите %s, чтобы скрыть.",
    TimerAlreadyShown = "Таймер уже отображается. Введите %s, чтобы скрыть.",
    TimerHidden = "Таймер скрыт. Введите %s, чтобы показать.",
    TimerAlreadyHidden = "Таймер уже скрыт. Введите %s, чтобы показать.",
    HelpShow = "%s – Показать таймер для позиционирования.",
    HelpHide = "%s – Скрыть таймер.",
    HelpMute = "%s – Показать, какие сообщения сейчас отключены.",
    HelpMuteLogin = "%s – Отключить или показать сообщение при входе.",
    HelpMuteReport = "%s – Отключить или показать отчет о полете.",
    HelpMuteAll = "%s – Отключить сообщение при входе и отчет о полете.",
    HelpMuteNone = "%s – Показать сообщение при входе и отчет о полете.",
    HelpDebug = "%s – Включить или отключить режим отладки.",
    HelpHelp = "%s – Показать эту справку.",
    HelpPaste = "Shift-клик по таймеру при вводе текста, чтобы вставить время прибытия.",
    UnknownCommand = "неизвестная команда: %s",
    Ready = "Готово. Введите %s для списка всех команд.",
    NoData = "Данные о длительности полетов отсутствуют. Введите %s для списка всех команд."
}

local koKR = {
    EstimatedTime = "예상 시간:",
    RecordedTime = "기록된 시간:",
    FlyingFrom = "출발지:",
    FlyingTo = "도착지:",
    PasteHint = "대화 입력 중 Shift-클릭하여 도착 시간을 붙여넣습니다.",

    ArrivalOverdue = "%s 도착 예정 시간이 %s 지연됨, 잠시 후 착륙합니다",
    ArrivalOverdueNoPlace = "도착 예정 시간이 %s 지연됨, 잠시 후 착륙합니다",
    Arriving = "%s까지 %s 후 도착",
    ArrivingNoPlace = "%s 후 도착",

    NewData = "새 데이터: %s에서 %s까지 %s 소요되었습니다.",
    Correction = "수정: %s에서 %s까지 %s 소요되었습니다 (이전: %s).",
    Arrived = "%s에 %s 후 도착했습니다.",
    FlightCancelled = "비행이 취소되었습니다.",
    UnknownFlight = "알 수 없는 비행 경로입니다. %s에서 %s까지의 시간을 측정합니다.",

    PinsUnavailable = "비행 지도 핀을 사용할 수 없습니다 (%s).",
    NoMapFrame = "지도 프레임 없음",

    DebugOn = "디버그 켜짐. 끄려면 %s 입력.",
    DebugOff = "디버그 꺼짐. 켜려면 %s 입력.",
    MuteLoginOn = "로그인 메시지 켜짐. 숨기려면 %s 입력.",
    MuteLoginOff = "로그인 메시지 꺼짐. 표시하려면 %s 입력.",
    MuteReportOn = "비행 보고 켜짐. 숨기려면 %s 입력.",
    MuteReportOff = "비행 보고 꺼짐. 표시하려면 %s 입력.",
    TimerShown = "위치 조정을 위해 타이머를 표시합니다. 숨기려면 %s 입력.",
    TimerAlreadyShown = "타이머가 이미 표시되어 있습니다. 숨기려면 %s 입력.",
    TimerHidden = "타이머가 숨겨졌습니다. 표시하려면 %s 입력.",
    TimerAlreadyHidden = "타이머가 이미 숨겨져 있습니다. 표시하려면 %s 입력.",
    HelpShow = "%s – 위치 조정을 위해 타이머 표시.",
    HelpHide = "%s – 타이머 숨기기.",
    HelpMute = "%s – 현재 음소거된 메시지 표시.",
    HelpMuteLogin = "%s – 로그인 메시지 숨기기/표시.",
    HelpMuteReport = "%s – 비행 보고 숨기기/표시.",
    HelpMuteAll = "%s – 로그인 메시지와 비행 보고 숨기기.",
    HelpMuteNone = "%s – 로그인 메시지와 비행 보고 표시.",
    HelpDebug = "%s – 디버그 출력 켜기/끄기.",
    HelpHelp = "%s – 도움말 표시.",
    HelpPaste = "대화 입력 중 타이머를 Shift-클릭하여 도착 시간을 붙여넣습니다.",
    UnknownCommand = "알 수 없는 명령어: %s",
    Ready = "준비 완료. 모든 명령어는 %s 입력.",
    NoData = "비행 시간 데이터가 없습니다. 모든 명령어는 %s 입력."
}

local zhCN = {
    EstimatedTime = "预计时间：",
    RecordedTime = "记录时间：",
    FlyingFrom = "出发地：",
    FlyingTo = "目的地：",
    PasteHint = "输入时按 Shift+左键 粘贴预计到达时间。",

    ArrivalOverdue = "到达 %s 已超时 %s，随时准备着陆",
    ArrivalOverdueNoPlace = "到达已超时 %s，随时准备着陆",
    Arriving = "将在 %2$s 后到达 %1$s",
    ArrivingNoPlace = "将在 %s 后到达",

    NewData = "新数据：从 %s 到 %s 用时 %s。",
    Correction = "修正：从 %s 到 %s 用时 %s（先前为 %s）。",
    Arrived = "于 %2$s 后到达 %1$s。",
    FlightCancelled = "飞行已取消。",
    UnknownFlight = "未知飞行路线。正在测量从 %s 到 %s 的时间。",

    PinsUnavailable = "飞行地图标记不可用（%s）。",
    NoMapFrame = "无地图框架",

    DebugOn = "调试模式已开启。输入 %s 关闭。",
    DebugOff = "调试模式已关闭。输入 %s 开启。",
    MuteLoginOn = "登录提示已开启。输入 %s 隐藏。",
    MuteLoginOff = "登录提示已关闭。输入 %s 显示。",
    MuteReportOn = "飞行报告已开启。输入 %s 隐藏。",
    MuteReportOff = "飞行报告已关闭。输入 %s 显示。",
    TimerShown = "已显示计时器以供调整位置。输入 %s 隐藏。",
    TimerAlreadyShown = "计时器已在显示中。输入 %s 隐藏。",
    TimerHidden = "计时器已隐藏。输入 %s 显示。",
    TimerAlreadyHidden = "计时器已在隐藏中。输入 %s 显示。",
    HelpShow = "%s – 显示计时器以调整位置。",
    HelpHide = "%s – 隐藏计时器。",
    HelpMute = "%s – 显示当前已关闭的提示信息。",
    HelpMuteLogin = "%s – 关闭或显示登录提示。",
    HelpMuteReport = "%s – 关闭或显示飞行报告。",
    HelpMuteAll = "%s – 关闭登录提示和飞行报告。",
    HelpMuteNone = "%s – 显示登录提示和飞行报告。",
    HelpDebug = "%s – 开启或关闭调试输出。",
    HelpHelp = "%s – 显示此帮助信息。",
    HelpPaste = "输入时按 Shift+左键 点击计时器以粘贴到达时间。",
    UnknownCommand = "未知命令：%s",
    Ready = "就绪。输入 %s 查看所有命令。",
    NoData = "未包含飞行时间数据。输入 %s 查看所有命令。"
}

local zhTW = {
    EstimatedTime = "預計時間：",
    RecordedTime = "記錄時間：",
    FlyingFrom = "出發地：",
    FlyingTo = "目的地：",
    PasteHint = "輸入時按 Shift+左鍵 貼上預計到達時間。",

    ArrivalOverdue = "到達 %s 已逾時 %s，隨時準備著陸",
    ArrivalOverdueNoPlace = "到達已逾時 %s，隨時準備著陸",
    Arriving = "將在 %2$s 後到達 %1$s",
    ArrivingNoPlace = "將在 %s 後到達",

    NewData = "新數據：從 %s 到 %s 用時 %s。",
    Correction = "修正：從 %s 到 %s 用時 %s（先前為 %s）。",
    Arrived = "於 %2$s 後到達 %1$s。",
    FlightCancelled = "飛行已取消。",
    UnknownFlight = "未知飛行路線。正在測量從 %s 到 %s 的時間。",

    PinsUnavailable = "飛行地圖標記不可用（%s）。",
    NoMapFrame = "無地圖框架",

    DebugOn = "調試模式已開啟。輸入 %s 關閉。",
    DebugOff = "調試模式已關閉。輸入 %s 開啟。",
    MuteLoginOn = "登入提示已開啟。輸入 %s 隱藏。",
    MuteLoginOff = "登入提示已關閉。輸入 %s 顯示。",
    MuteReportOn = "飛行報告已開啟。輸入 %s 隱藏。",
    MuteReportOff = "飛行報告已關閉。輸入 %s 顯示。",
    TimerShown = "已顯示計時器以供調整位置。輸入 %s 隱藏。",
    TimerAlreadyShown = "計時器已在顯示中。輸入 %s 隱藏。",
    TimerHidden = "計時器已隱藏。輸入 %s 顯示。",
    TimerAlreadyHidden = "計時器已在隱藏中。輸入 %s 顯示。",
    HelpShow = "%s – 顯示計時器以調整位置。",
    HelpHide = "%s – 隱藏計時器。",
    HelpMute = "%s – 顯示目前已關閉的提示訊息。",
    HelpMuteLogin = "%s – 關閉或顯示登入提示。",
    HelpMuteReport = "%s – 關閉或顯示飛行報告。",
    HelpMuteAll = "%s – 關閉登入提示和飛行報告。",
    HelpMuteNone = "%s – 顯示登入提示和飛行報告。",
    HelpDebug = "%s – 開啟或關閉調試輸出。",
    HelpHelp = "%s – 顯示此說明訊息。",
    HelpPaste = "輸入時按 Shift+左鍵 點擊計時器以貼上到達時間。",
    UnknownCommand = "未知指令：%s",
    Ready = "就緒。輸入 %s 查看所有指令。",
    NoData = "未包含飛行時間數據。輸入 %s 查看所有指令。"
}

local locales = {
    enUS = enUS,
    enGB = enUS,
    deDE = deDE,
    esES = es,
    esMX = es,
    frFR = frFR,
    itIT = itIT,
    koKR = koKR,
    ptBR = ptBR,
    ruRU = ruRU,
    zhCN = zhCN,
    zhTW = zhTW
}

local L = locales[GetLocale()] or enUS
-- A partial translation still shows English for the lines it skips.
if L ~= enUS then
    setmetatable(L, {
        __index = enUS
    })
end

ns.L = L
