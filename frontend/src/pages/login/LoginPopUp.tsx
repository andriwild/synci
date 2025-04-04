import {FC, useEffect, useState} from "react";
import {Modal, Button, Flex, Typography, Divider, Image} from "antd";
import {VITE_KEYCLOAK_HOST, VITE_SECRET_KEYCLOAK, VITE_CLIENT_ID_KEYCLOAK} from "../../../env.ts";
import {userActions} from "../../services/user/UserSlice.ts";
import {useDispatch} from "react-redux";
import {IconBrandGithub, IconBrandGoogle} from "@tabler/icons-react";

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
            }, 200);
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

                // Refresh_Token speichern
                localStorage.setItem("refresh_token", data.refresh_token);

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



    return (
        <Modal
            open={isOpen}
            onCancel={onClose}
            cancelText={"Abbrechen"}
            footer={null}
        >
            <Flex vertical gap={20} align={"center"} style={{ padding: 20 }}>
                <Image
                    src={"./assets/Logo_synci.png"}
                    preview={false}
                    style={{
                        cursor: "pointer",
                        maxHeight: 60,
                    }}
                />
                <Typography.Title level={1}>Login</Typography.Title>
                <Flex vertical gap={20}>
            <Button type="default"
                    size={"large"}
                    icon={<IconBrandGoogle/>}
                    onClick={ () => {
                    openAuthPopup("google")
            }}>
                Mit Google anmelden
            </Button>
            <Button type="default"
                    size={"large"}
                    icon={<IconBrandGithub/>}
                    onClick={ () => {
                openAuthPopup("github")
            }}>
                Mit GitHub anmelden
            </Button>
            </Flex>
                <Divider style={{marginBottom: 0}}>Warum muss ich mich anmelden?</Divider>
                <Flex vertical align={"center"} gap={10}>
                    <Typography.Text>Erstelle deine eigenen Abonemente</Typography.Text>
                    <Typography.Text>Komm später zurück und passe deine Abonemente an</Typography.Text>
                </Flex>
            </Flex>
        </Modal>
    );
};
