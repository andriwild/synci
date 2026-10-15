import {FC} from "react";
import {Link} from "react-router-dom";
import "./AppShell.css";

export const Footer: FC = () => {
    return (
        <footer className="app-footer">
            <Link to="/impressum">Impressum & Datenschutz</Link>
            <Link to="/faq">FAQ</Link>
        </footer>
    );
};
