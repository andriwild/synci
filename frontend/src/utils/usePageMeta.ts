import {useEffect} from "react";

const HOME_TITLE = "Synci – Sportevents automatisch in deinem Kalender";
const HOME_DESCRIPTION = document.querySelector('meta[name="description"]')?.getAttribute("content") ?? "";

const setAttribute = (selector: string, attribute: string, value: string) =>
    document.querySelector(selector)?.setAttribute(attribute, value);

/** title, description and canonical URL of a page; without a title the home page's */
export const usePageMeta = (title?: string, description?: string) => {
    useEffect(() => {
        document.title = title ? `${title} – Synci` : HOME_TITLE;
        setAttribute('meta[name="description"]', "content", description ?? HOME_DESCRIPTION);
        setAttribute('link[rel="canonical"]', "href", `https://synci.ch${window.location.pathname}`);
    }, [title, description]);
};
