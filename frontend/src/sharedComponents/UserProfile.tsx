import {Avatar, Button, Divider, Flex, Popover, Spin, theme, Typography} from "antd";
import Title from "antd/es/typography/Title";
import {CalendarBlank, UserCircle, UsersThree} from "@phosphor-icons/react";
import {useNavigate} from "react-router-dom";
import {useAuth0} from "@auth0/auth0-react";
import {userActions, useUser} from "../services/user/UserSlice.ts";
import {useDispatch} from "react-redux";
import {useState} from "react";
import {useResponsive} from "../utils/useResponsive.ts";
import {track} from "../utils/analytics.ts";

export const UserProfile = () => {
    const {token} = theme.useToken();
    const navigate = useNavigate();
    const user = useUser();
    const dispatch = useDispatch();
    const {isMobile, isDesktop, isXs} = useResponsive();

    const [opened, setOpened] = useState(false);

    const {
        isLoading,
        loginWithRedirect: login,
        logout: auth0Logout,
    } = useAuth0();

    const signup = () => {
        track("signup-click");
        login({authorizationParams: {screen_hint: "signup"}});
    };

    const logout = () => {
        auth0Logout({logoutParams: {returnTo: window.location.origin}}).then(() => {
                dispatch(userActions.clearUser());
                setOpened(false);
            }
        );
    };

    const go = (path: string) => {
        setOpened(false);
        navigate(path);
    };

    if (isLoading) return <Spin size="small"/>;

    const avatar = (
        <Avatar
            src={user?.picture || undefined}
            icon={<UserCircle size={28}/>}
            size={40}
            style={{flexShrink: 0, cursor: "pointer", background: token.colorBgContainer, color: token.colorPrimary}}
        />
    );

    if (!user) {
        return (
            <Flex align="center" gap={8} style={{flexShrink: 0}}>
                {/* "Konto erstellen" moves into the drawer on phones to keep the header free */}
                {!isXs && <Button onClick={signup}>Konto erstellen</Button>}
                <Button type="primary" onClick={() => {
                    track("login-click");
                    login();
                }}>Anmelden</Button>
            </Flex>
        );
    }

    return (
        <Popover
            placement="bottomRight"
            // hover does not exist on touch screens
            trigger={isMobile ? "click" : "hover"}
            showArrow={false}
            open={opened}
            onOpenChange={(open) => setOpened(open)}
            styles={{
                body: {
                    padding: "20px",
                    width: "min(300px, calc(100vw - 32px))",
                    borderRadius: token.borderRadius,
                },
            }}
            content={
                <Flex vertical style={{alignItems: "start", gap: 10}}>
                    <Flex style={{alignItems: "center", gap: 16, minWidth: 0, width: "100%"}}>
                        {avatar}
                        <Title level={5} style={{margin: 0, minWidth: 0, overflowWrap: "anywhere"}}>{user.email}</Title>
                    </Flex>
                    <Divider style={{borderColor: token.colorPrimary, margin: "8px 0"}}>
                        <Typography.Title level={5} style={{margin: 0, fontSize: "0.8rem"}}>Einstellungen</Typography.Title>
                    </Divider>
                    <Button icon={<CalendarBlank/>} onClick={() => go("/syncConfig")} type="text" block style={{justifyContent: "flex-start"}}>
                        Meine Abos
                    </Button>
                    <Button icon={<UsersThree/>} onClick={() => go("/organisationen")} type="text" block style={{justifyContent: "flex-start"}}>
                        Meine Organisationen
                    </Button>
                    <Button
                        type="default"
                        size="large"
                        block
                        style={{marginTop: 12}}
                        onClick={() => window.open("https://buymeacoffee.com/boostershack", "_blank")}
                    >
                        Synci unterstützen
                    </Button>
                    <Button type="primary" block size="large" onClick={logout}>
                        Abmelden
                    </Button>
                </Flex>
            }
        >
            <Flex align="center" gap={10} style={{cursor: "pointer", flexShrink: 0, minWidth: 0}}>
                {isDesktop && (
                    <Flex vertical align="flex-end" style={{minWidth: 0}}>
                        <Typography.Text type="secondary" style={{margin: 0, whiteSpace: "nowrap"}}>Mein Konto</Typography.Text>
                        <Title level={5} style={{margin: 0, maxWidth: 220}} ellipsis>{user.email}</Title>
                    </Flex>
                )}
                {avatar}
            </Flex>
        </Popover>
    );
};
