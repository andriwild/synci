declare global {
    interface Window {
        umami?: {
            track: (event: string, data?: Record<string, string | number>) => void;
        };
    }
}

export type SubscriptionType = "sport" | "team" | "event";
export type CalendarProvider = "apple" | "google" | "outlook" | "copy";

type AnalyticsEvents = {
    "sport-select": { sport: string; level: number };
    "subscription-add": { type: SubscriptionType; name: string; sport?: string };
    "subscription-remove": { type: SubscriptionType; name: string; sport?: string };
    "calendar-modal-open": undefined;
    "calendar-add": { provider: CalendarProvider };
    "abo-create": undefined;
    "abo-delete": undefined;
    "login-click": undefined;
    "signup-click": undefined;
    "app-store-click": { store: "apple" | "google" };
};

// No personal data (email, user ID, sync config names)
export const track = <E extends keyof AnalyticsEvents>(
    event: E,
    ...[data]: AnalyticsEvents[E] extends undefined ? [] : [AnalyticsEvents[E]]
) => {
    try {
        const cleaned = data
            ? Object.fromEntries(Object.entries(data).filter(([, v]) => v !== undefined && v !== ""))
            : undefined;
        window.umami?.track(event, cleaned);
    } catch {
        // Tracking must never break the app (e.g. ad blockers)
    }
};
