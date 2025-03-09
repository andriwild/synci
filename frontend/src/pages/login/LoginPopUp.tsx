import {FC, useEffect, useState} from "react";
import { Modal, Button } from "antd";
import {VITE_KEYCLOAK_HOST, VITE_SECRET_KEYCLOAK, VITE_CLIENT_ID_KEYCLOAK} from "../../../env.ts";
import {userActions} from "../../services/user/UserSlice.ts";
import {useDispatch} from "react-redux";

interface LoginPageProps {
    isOpen: boolean;
    onClose: () => void;
}

export const LoginPopUp : FC<LoginPageProps> = ({ isOpen, onClose }) => {
    const URL_ADDON = "/realms/synci/protocol/openid-connect/auth";
    const CLIENT_ID = VITE_CLIENT_ID_KEYCLOAK;
    const REDIRECT_URI = window.location.href;
    const RESPONSE_TYPE = "code";
    const SCOPE = "openid";
    const [authCode, setAuthCode] = useState("");
    const [accessToken, setAccessToken] = useState(localStorage.getItem("access_token") || null);
    const dispatch = useDispatch();

    const openAuthPopup = (idpHint: string) => {
        const authUrl = `${VITE_KEYCLOAK_HOST + URL_ADDON}?client_id=${CLIENT_ID}&redirect_uri=${encodeURIComponent(REDIRECT_URI)}&response_type=${RESPONSE_TYPE}&scope=${SCOPE}&kc_idp_hint=${idpHint}`;

        const width = 500;
        const height = 600;
        const top = (window.innerHeight - height) / 2;

        const popup = window.open(
            authUrl,
            "auth-popup",
            `width=${width},height=${height},top=${top},resizable=no,scrollbars=no,status=no`
        );

        if (popup) {
            const interval = setInterval(() => {
                try {
                    if (popup.closed) {
                        clearInterval(interval);
                        onClose();
                    }
                    const popupUrl = new URL(popup.location.href);
                    const code = popupUrl.searchParams.get("code");
                    if (code) {
                        setAuthCode(code);
                        popup.close();
                        clearInterval(interval);
                        onClose();
                    }
                } catch (error) {
                    console.error("Fehler beim Abrufen des Codes:", error);
                    clearInterval(interval);
                    onClose();
                }
            }, 1000);
        }
    };

    const decodeJwt = (token: string) => {
        try {
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            return JSON.parse(atob(base64));
        } catch (error) {
            console.error("Fehler beim Dekodieren des Tokens:", error);
            return {};
        }
    };

    useEffect(() => {
        if (!authCode) return;

        const exchangeCodeForToken = async () => {
            try {
                const response = await fetch(`${VITE_KEYCLOAK_HOST}/realms/synci/protocol/openid-connect/token`, {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: new URLSearchParams({
                        client_id: VITE_CLIENT_ID_KEYCLOAK,
                        client_secret: VITE_SECRET_KEYCLOAK,
                        redirect_uri: window.location.href,
                        grant_type: "authorization_code",
                        code: authCode,
                    }),
                });

                if (!response.ok) {
                    console.error(`Fehler beim Token-Request: ${response.status} - ${response.statusText}`);
                    return;
                }

                const data = await response.json();

                if (!data.access_token) {
                    console.error("Fehler beim Abrufen des Tokens:", data);
                    return;
                }

                // Token speichern
                localStorage.setItem("access_token", data.access_token);
                setAccessToken(data.access_token);

                // Token decodieren
                const decodedToken = decodeJwt(data.access_token);

                // User-Informationen setzen
                dispatch(userActions.setUser({
                    firstName: decodedToken.given_name || "",
                    lastName: decodedToken.family_name || "",
                    email: decodedToken.email || "",
                }));

            } catch (error) {
                console.error("Fehler beim Token-Austausch:", error);
            }
        };

        void exchangeCodeForToken(); // Verhindert TypeScript-Warnung
    }, [authCode, dispatch]);


    const logout = async () => {
        const token = localStorage.getItem("access_token");

        if (!token) {
            console.warn("Kein Token gefunden – Benutzer ist möglicherweise bereits abgemeldet.");
            return;
        }

        const logoutUrl = `${VITE_KEYCLOAK_HOST}/realms/synci/protocol/openid-connect/logout`;

        try {
            const response = await fetch(logoutUrl, {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({
                    client_id: VITE_CLIENT_ID_KEYCLOAK,
                    client_secret: VITE_SECRET_KEYCLOAK,
                }),
            });

            if (response.ok) {

                // Lokale Token löschen
                localStorage.removeItem("access_token");
                setAccessToken(null);
            } else {
                console.error("Fehler beim Logout:", await response.text());
            }
        } catch (error) {
            console.error("Fehler bei der Logout-Anfrage:", error);
        }
    };



    return (
        <Modal
            title="Mit OAUTH anmelden"
            open={isOpen}
            onCancel={onClose}
            footer={null}
        >
            <Button type="primary" onClick={ () => {
                    openAuthPopup("google")
            }}>
                Mit Google anmelden
            </Button>
            <Button type="primary" onClick={ () => {
                openAuthPopup("github")
            }}>
                Mit github anmelden
            </Button>
            <Button type="primary" danger onClick={logout}>
                Abmelden
            </Button>


            {authCode && <p>Authentifizierung erfolgreich! Code: {authCode}</p>}
            {accessToken && <p>AccessToken: {accessToken}</p>}
        </Modal>
    );
};
