import {useEffect, useRef, useState} from "react";
import { Modal, Button } from "antd";
import {VITE_KEYCLOAK_HOST, VITE_SECRET_KEYCLOAK, VITE_CLIENT_ID_KEYCLOAK} from "../../../env.ts";
import {userActions, useUser} from "../../services/user/UserSlice.ts";
import {useDispatch} from "react-redux";


export const Login = ({ isOpen, onClose }) => {
    const URL_ADDON = "/realms/synci/protocol/openid-connect/auth";
    const CLIENT_ID = VITE_CLIENT_ID_KEYCLOAK;
    const REDIRECT_URI = window.location.href;
    const RESPONSE_TYPE = "code";
    const SCOPE = "openid";
    const [authCode, setAuthCode] = useState("");
    const [accessToken, setAccessToken] = useState(localStorage.getItem("access_token") || null);
    const user= useUser();
    const dispatch = useDispatch();

    const openAuthPopup = (idpHint) => {
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

    useEffect(() => {
        if (authCode) {
            const exchangeCodeForToken = async () => {
                try {
                    const response = await fetch(`${VITE_KEYCLOAK_HOST}/realms/synci/protocol/openid-connect/token`, {
                        method: "POST",
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: new URLSearchParams({
                            client_id: VITE_CLIENT_ID_KEYCLOAK,
                            client_secret: VITE_SECRET_KEYCLOAK,
                            redirect_uri:  window.location.href,
                            grant_type: "authorization_code",
                            code: authCode,
                        }),
                    });

                    const data = await response.json();
                    if (data.access_token) {
                        localStorage.setItem("access_token", data.access_token);
                        setAccessToken(data.access_token);
                        //decode token
                        const base64Url = data.access_token.split('.')[1];
                        const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
                        const jsonPayload = decodeURIComponent(atob(base64).split('').map(function(c) {
                            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
                        }).join(''));
                        console.log("Decoded Token:", JSON.parse(jsonPayload));
                        dispatch(userActions.setUser({
                            firstName: JSON.parse(jsonPayload).given_name,
                            lastName: JSON.parse(jsonPayload).family_name,
                            email: JSON.parse(jsonPayload).email,
                        }));
                        console.log("Access Token gespeichert:", data.access_token);
                    } else {
                        console.error("Fehler beim Abrufen des Tokens:", data);
                    }
                } catch (error) {
                    console.error("Fehler beim Token-Austausch:", error);
                }
            };

            exchangeCodeForToken();
        }
    }, [authCode]);

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
                    // refresh_token: token,
                }),
            });

            if (response.ok) {
                console.log("Erfolgreich abgemeldet");

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
