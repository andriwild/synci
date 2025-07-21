import {FC} from "react";
import {Modal, Button, Flex, Typography, Divider, Image} from "antd";
import {IconBrandGithub, IconBrandGoogle} from "@tabler/icons-react";
import keycloak from "../../utils/keycloak.ts";

interface LoginPageProps {
    isOpen: boolean;
    onClose: () => void;
}

export const LoginPopUp: FC<LoginPageProps> = ({isOpen, onClose}) => {

    const openAuthPopup = (idpHint: string) => {
        keycloak.login({
            idpHint: idpHint,
            redirectUri: window.location.origin + window.location.pathname
        }).then()
    };


    return (
        <Modal
            open={isOpen}
            onCancel={onClose}
            cancelText={"Abbrechen"}
            footer={null}
        >
            <Flex vertical gap={20} align={"center"} style={{padding: 20}}>
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
                            onClick={() => {
                                openAuthPopup("google")
                            }}>
                        Mit Google anmelden
                    </Button>
                    <Button type="default"
                            size={"large"}
                            icon={<IconBrandGithub/>}
                            onClick={() => {
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
