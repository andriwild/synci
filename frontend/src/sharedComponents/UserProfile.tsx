import {Button, Divider, Flex, Image, Popover, theme, Typography} from "antd";
import Title from "antd/es/typography/Title";
import {CalendarBlank} from "@phosphor-icons/react";
import {useNavigate} from "react-router-dom";
import {useAuth0} from "@auth0/auth0-react";

export const UserProfile = () => {
    const {token} = theme.useToken();
    const navigate = useNavigate();

    const {
        isLoading, // Loading state, the SDK needs to reach Auth0 on load
        isAuthenticated,
        error,
        loginWithRedirect: login, // Starts the login flow
        logout: auth0Logout, // Starts the logout flow
        user, // User profile
    } = useAuth0();

    const signup = () =>
        login({ authorizationParams: { screen_hint: "signup" } });

    const logout = () =>
        auth0Logout({ logoutParams: { returnTo: window.location.origin } });

    if (isLoading) return "Loading...";

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
                            <Title level={5} style={{margin: 0}} color={token.colorPrimary}>{user.firstName + ' ' + user.lastName}</Title>
                        </Flex>
                    </Flex>
                    <Divider
                        variant={"solid"}
                        style={{borderColor: token.colorPrimary}}
                    >
                        <Typography.Title level={5} style={{margin: 0, fontSize:'0.8rem'}}>Einstellungen</Typography.Title>
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
                            onClick={logout} // Logout function
                        >
                            Abmelden
                        </Button>
                </Flex>
                    }
        >
            <Flex style={{alignItems: 'center', cursor: 'pointer', gap: 10}}>
                {isAuthenticated ?
                    <>

                <Flex style={{flexDirection: 'column', alignItems: 'flex-end'}}>
                    <Typography.Text type={'secondary'} style={{margin: 0}}>Mein Konto</Typography.Text>
                   <Title level={5} style={{margin: 0}} color={token.colorPrimary}>{user?.email}</Title>
                </Flex>
                <Image
                    src={user?.picture || '../assets/Profile_sample.png'}
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
                        <Button onClick={signup}>Konto Erstellen</Button>
                        <Button type={'primary'} onClick={login}>Anmelden</Button>
                    </>
                }
            </Flex>
        </Popover>
    );
}
