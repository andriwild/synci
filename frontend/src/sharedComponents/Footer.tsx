import {FC} from "react";
import {Link} from "react-router-dom";
import "./AppShell.css";

export const Footer: FC = () => {
    return (
        <footer className="app-footer">
            <Link to="/impressum">Impressum</Link>
            <Link to="/datenschutz">Datenschutz</Link>
            <Link to="/faq">FAQ</Link>
        </footer>
    );
};
