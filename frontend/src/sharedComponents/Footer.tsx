import {FC} from "react";
import {Link} from "react-router-dom";
import "./AppShell.css";

/* Impressum and Datenschutz get their own pages in a later step; until then they share the FAQ page. */
export const Footer: FC = () => {
    return (
        <footer className="app-footer">
            <Link to="/impressum">Impressum & Datenschutz</Link>
            <Link to="/faq">FAQ</Link>
        </footer>
    );
};
