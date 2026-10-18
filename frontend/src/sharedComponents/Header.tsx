import {FC, useState} from "react";
import {Button, Drawer, Flex, Layout, Menu, theme, Typography} from "antd";
import {useLocation, useNavigate} from "react-router-dom";
import {CalendarBlank, Coffee, ListBullets, UsersThree} from "@phosphor-icons/react";
import {UserProfile} from "./UserProfile.tsx";
import {IconMenu2} from "@tabler/icons-react";
import type {MenuProps} from "antd";
import {useAuth0} from "@auth0/auth0-react";
import {useResponsive} from "../utils/useResponsive.ts";
import {useUser} from "../services/user/UserSlice.ts";
import "./AppShell.css";

export const Header: FC = () => {
    const navigate = useNavigate();
    const location = useLocation();
    const {isMobile} = useResponsive();
    const [visible, setVisible] = useState(false);
    const user = useUser();
    const {loginWithRedirect} = useAuth0();

    const items: MenuProps["items"] = [
        {
            key: "/sport",
            label: "Sportarten",
            icon: <ListBullets/>,
        },
        ...(user ? [{
            key: "/syncConfig",
            label: "Meine Abos",
            icon: <CalendarBlank/>,
        }, {
            key: "/organisationen",
            label: "Meine Organisationen",
            icon: <UsersThree/>,
        }] : [])
    ];

    const handleMenuClick: MenuProps["onClick"] = (info) => {
        navigate(info.key);
        setVisible(false);
    };

    const {token} = theme.useToken();
    const selectedKey = items
        .map((item) => String(item?.key))
        .find((key) => location.pathname === key || location.pathname.startsWith(key + "/")) ?? location.pathname;

    const logo = (
        <img
            src="/assets/Logo_synci.png"
            alt="Synci"
            className="app-header__logo"
            onClick={() => navigate("/")}
        />
    );

    return (
        <Layout.Header className="app-header">
            {isMobile ? (
                <>
                    <Button
                        type="text"
                        size="large"
                        aria-label="Menü öffnen"
                        onClick={() => setVisible(true)}
                        icon={<IconMenu2 size={24}/>}
                    />
                    {logo}
                    <span className="app-header__spacer"/>
                    <Drawer title="Menü"
                            placement="left"
                            width="min(300px, 85vw)"
                            onClose={() => setVisible(false)}
                            open={visible}
                            styles={{body: {display: "flex", flexDirection: "column", padding: 0}}}>
                        <Menu
                            mode="vertical"
                            items={items}
                            style={{
                                flex: "0 0 auto",
                                minWidth: 0,
                                border: "none",
                                backgroundColor: "transparent",
                                paddingTop: 8,
                            }}
                            onClick={handleMenuClick}
                            selectedKeys={[selectedKey]}
                        />
                        <Flex
                            vertical
                            align="center"
                            gap={12}
                            style={{
                                marginTop: "auto",
                                padding: 24,
                                borderTop: `1px solid ${token.colorSplit}`,
                            }}
                        >
                            {!user &&
                                <Button
                                    block
                                    style={{height: 48}}
                                    onClick={() => loginWithRedirect({authorizationParams: {screen_hint: "signup"}})}
                                >
                                    Konto erstellen
                                </Button>}
                            <Button
                                type="primary"
                                block
                                icon={<Coffee size={18} weight="fill"/>}
                                style={{height: 48, fontWeight: 600}}
                                onClick={() => {
                                    window.open("https://buymeacoffee.com/boostershack", "_blank");
                                }}
                            >
                                Team unterstützen
                            </Button>
                            <Typography.Text type="secondary" style={{fontSize: 12}}>
                                Version {__APP_VERSION__} · © 2026 Synci
                            </Typography.Text>
                        </Flex>
                    </Drawer>
                </>
            ) : (
                <>
                    {logo}
                    <Menu
                        mode="horizontal"
                        items={items}
                        className="app-header__nav"
                        style={{backgroundColor: "white"}}
                        onClick={handleMenuClick}
                        selectedKeys={[selectedKey]}
                    />
                </>
            )}
            <UserProfile/>
        </Layout.Header>
    );
};
