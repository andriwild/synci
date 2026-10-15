const LOCALE = "de-CH";

export const convertToSwissDate = (date: string): string => {
    const dateObj = new Date(date);
    return dateObj.toLocaleDateString(LOCALE);
}

/** Stable key of the local calendar day, used to group events ("2026-10-23"). */
export const dayKey = (iso: string): string => {
    const d = new Date(iso);
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
};

/** "Donnerstag, 23. Oktober" – the year is added only when it differs from the current year. */
export const formatDayHeading = (iso: string, now: Date = new Date()): string => {
    const d = new Date(iso);
    return d.toLocaleDateString(LOCALE, {
        weekday: "long",
        day: "numeric",
        month: "long",
        ...(d.getFullYear() !== now.getFullYear() ? {year: "numeric"} : {}),
    });
};

/** "14:30" */
export const formatTime = (iso: string): string =>
    new Date(iso).toLocaleTimeString(LOCALE, {hour: "2-digit", minute: "2-digit"});
