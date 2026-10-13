import {useEffect} from "react";

const SITE_NAME = "Synci";
const SITE_URL = "https://synci.ch";
const DEFAULT_DESCRIPTION = "Abonniere Ligen, Teams und Events als Kalender-Abo. Alle Spiele automatisch in Google Kalender, Outlook und Apple Kalender.";

type PageMeta = {
    /** page title without the site name; the site name is appended */
    title: string;
    description?: string;
    /** path for the canonical URL, defaults to the current path */
    path?: string;
    /** keeps private pages out of the index */
    noindex?: boolean;
};

const upsertMeta = (selector: string, attributes: Record<string, string>) => {
    let element = document.head.querySelector<HTMLElement>(selector);
    if (!element) {
        element = document.createElement(selector.startsWith("link") ? "link" : "meta");
        document.head.appendChild(element);
    }
    Object.entries(attributes).forEach(([key, value]) => element!.setAttribute(key, value));
};

/**
 * Sets title, description, canonical and robots for the current route. The SPA ships one index.html
 * for every URL, so without this every page would carry the same head.
 */
export const usePageMeta = ({title, description, path, noindex}: PageMeta) => {
    useEffect(() => {
        const fullTitle = `${title} | ${SITE_NAME}`;
        const text = description ?? DEFAULT_DESCRIPTION;
        const canonical = `${SITE_URL}${path ?? window.location.pathname}`;

        document.title = fullTitle;
        upsertMeta('meta[name="description"]', {name: "description", content: text});
        upsertMeta('link[rel="canonical"]', {rel: "canonical", href: canonical});
        upsertMeta('meta[property="og:title"]', {property: "og:title", content: fullTitle});
        upsertMeta('meta[property="og:description"]', {property: "og:description", content: text});
        upsertMeta('meta[property="og:url"]', {property: "og:url", content: canonical});
        upsertMeta('meta[name="twitter:title"]', {name: "twitter:title", content: fullTitle});
        upsertMeta('meta[name="twitter:description"]', {name: "twitter:description", content: text});
        upsertMeta('meta[name="robots"]', {name: "robots", content: noindex ? "noindex, nofollow" : "index, follow"});
    }, [title, description, path, noindex]);
};
