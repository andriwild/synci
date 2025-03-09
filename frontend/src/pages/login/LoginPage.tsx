import { useEffect, useState } from "react";
import { Modal, Button } from "antd";
import {useGetAuthUrlQuery, userApi} from "../../services/user/userApi.ts";
import {KEYCLOAK_HOST} from "../../../env.ts";


export const LoginPage = ({ isOpen, onClose }) => {

    const KEYCLOAK_AUTH_URL = `http://localhost:8090/realms/synci/protocol/openid-connect/auth`;
    const CLIENT_ID = "synci-backend";
    const REDIRECT_URI = "http://localhost:5173/sport";
    const RESPONSE_TYPE = "code";
    const SCOPE = "openid";
    const IDP_HINT = "google";


    // const { data: authUrl, isLoading } = userApi.useGetAuthUrlQuery();
    const [authCode, setAuthCode] = useState(null);
    const [accessToken, setAccessToken] = useState(localStorage.getItem("access_token") || null);
    const urlParams = new URLSearchParams(window.location.search);

    const authUrl = `${KEYCLOAK_AUTH_URL}?client_id=${CLIENT_ID}&redirect_uri=${encodeURIComponent(REDIRECT_URI)}&response_type=${RESPONSE_TYPE}&scope=${SCOPE}&kc_idp_hint=${IDP_HINT}`;

    const openAuthPopup = () => {
        const width = 500;
        const height = 600;
        const top = (window.innerHeight - height) / 2;

        const popup = window.open(
            authUrl,
            "google-auth-popup",
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

    // Tausche den Authorization-Code gegen einen Access-Token aus
    useEffect(() => {
        if (authCode) {
            const exchangeCodeForToken = async () => {
                try {
                    const response = await fetch("http://localhost:8090/realms/synci/protocol/openid-connect/token", {
                        method: "POST",
                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                        body: new URLSearchParams({
                            client_id: "synci-backend",
                            client_secret: "qsRBHYpRSoqE5XrCCQE1iM6BqdK66tDK",
                            redirect_uri: "http://localhost:5173/sport",
                            grant_type: "authorization_code",
                            code: authCode,
                        }),
                    });

                    const data = await response.json();
                    if (data.access_token) {
                        localStorage.setItem("access_token", data.access_token); // Speichert den Token
                        setAccessToken(data.access_token); // Speichert den Token im State
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

    return (
        <Modal
            title="Mit Google anmelden"
            open={isOpen}
            onCancel={onClose}
            footer={null}
        >
            <Button type="primary" onClick={openAuthPopup}>
                Mit Google anmelden
            </Button>

            {authCode && <p>Authentifizierung erfolgreich! Code: {authCode}</p>}
            {accessToken && <p>AccessToken: {accessToken}</p>}
        </Modal>
    );
};
