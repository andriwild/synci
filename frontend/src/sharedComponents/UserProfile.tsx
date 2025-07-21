import {Button, Divider, Flex, Image, Popover, theme, Typography} from "antd";
import Title from "antd/es/typography/Title";
import {FC, useEffect, useState} from "react";
import {CalendarBlank} from "@phosphor-icons/react";
import {userActions, useUser} from "../services/user/UserSlice";
import {useNavigate} from "react-router-dom";
import {LoginPopUp} from "../pages/login/LoginPopUp.tsx";
import keycloak, {initKeycloak, logout} from "../utils/keycloak.ts";
import {useDispatch} from "react-redux";
import {KeycloakTokenParsed} from "keycloak-js";

export const UserProfile: FC = () => {
    const {token} = theme.useToken();
    const user = useUser()
    const navigate = useNavigate();
    const [isLoginModalOpen, setIsLoginModalOpen] = useState(false);
    const dispatch = useDispatch();


    useEffect(() => {
        initKeycloak()
            .then(authenticated => {
                console.log("keycloak.idTokenParsed: ", keycloak.idTokenParsed)
                if (!authenticated) return;
                // User aus idTokenParsed ziehen
                const {given_name, family_name, email} = keycloak.idTokenParsed as KeycloakTokenParsed;
                dispatch(userActions.setUser({
                    firstName: given_name,
                    lastName: family_name,
                    email
                }));
            })
            .catch(console.error)
    }, [dispatch]);

    keycloak.onAuthLogout = () => {
        console.log("User logged out!");
    };

    const handleLogout = async () => {
        try {
            await logout();
            keycloak.clearToken();
            dispatch(userActions.clearUser());
        } catch (err) {
            console.error('Logout fehlgeschlagen', err);
        }
    };

    return (
        <Popover
            placement="bottomRight"
            trigger={"hover"}
            showArrow={false}
            styles={{
                body: {
                    padding: '20px',
                    width: '300px',
                    borderRadius: token.borderRadius,
                },
            }}
            content={
                user &&
                <Flex vertical style={{alignItems: 'start', cursor: 'pointer', gap: 10}}>
                    <Flex style={{alignItems: 'center', cursor: 'pointer', gap: 20}}>
                        <Image
                            src={'../assets/Profile_sample.png'}
                            preview={false}
                            style={{
                                cursor: 'pointer',
                                borderRadius: '50%',
                                height: 40,
                                width: 40,
                                objectFit: 'cover',
                            }
                            }
                        />
                        <Flex style={{flexDirection: 'column', alignItems: 'flex-end'}}>
                            <Title level={5} style={{margin: 0}}
                                   color={token.colorPrimary}>{user.firstName + ' ' + user.lastName}</Title>
                        </Flex>
                    </Flex>
                    <Divider
                        variant={"solid"}
                        style={{borderColor: token.colorPrimary}}
                    >
                        <Typography.Title level={5}
                                          style={{margin: 0, fontSize: '0.8rem'}}>Einstellungen</Typography.Title>
                    </Divider>
                    <Button icon={<CalendarBlank/>}
                            onClick={() => {
                                navigate('/syncConfig')
                            }
                            }
                            type={'text'} style={{textAlign: 'start'}}>
                        Meine Kalender
                    </Button>
                    {/*<Button icon={<UserCircle/>} type={'text'} style={{textAlign: 'start'}}>*/}
                    {/*    Profil bearbeiten*/}
                    {/*</Button>*/}
                    <Button
                        type={'default'}
                        size={"large"}
                        style={{
                            width: '100%',
                            marginTop: '20px',
                        }}
                        onClick={() => {
                            window.open('https://buymeacoffee.com/boostershack', '_blank');
                        }}
                    >
                        Synci unterstützen
                    </Button>

                    <Button
                        type={'primary'}
                        style={{width: '100%'}}
                        size={"large"}
                        onClick={handleLogout}
                    >
                        Abmelden
                    </Button>
                </Flex>
            }
        >
            <Flex style={{alignItems: 'center', cursor: 'pointer', gap: 10}}>
                {user ?
                    <>
                        <Flex style={{flexDirection: 'column', alignItems: 'flex-end'}}>
                            <Typography.Text type={'secondary'} style={{margin: 0}}>Mein Konto</Typography.Text>
                            <Title level={5} style={{margin: 0}}
                                   color={token.colorPrimary}>{user.firstName + ' ' + user.lastName}</Title>
                        </Flex>
                        <Image
                            src={'../assets/Profile_sample.png'}
                            preview={false}
                            style={{
                                cursor: 'pointer',
                                borderRadius: '50%',
                                height: 40,
                                width: 40,
                                objectFit: 'cover',
                            }
                            }
                        />
                    </>
                    :
                    <>
                    <Button onClick={() => setIsLoginModalOpen(true)}>Anmelden</Button>
                    <LoginPopUp isOpen={isLoginModalOpen} onClose={() => setIsLoginModalOpen(false)} />
                    </>
                }
            </Flex>
        </Popover>
    );
}
