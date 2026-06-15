import { FC, useState } from "react";
import {Button, Drawer, Flex, Image, Layout, Menu, theme, Typography} from "antd";
import { useLocation, useNavigate } from "react-router-dom";
import { CalendarBlank, Coffee, ListBullets } from "@phosphor-icons/react";
import { UserProfile } from "./UserProfile.tsx";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";
import { IconMenu2 } from "@tabler/icons-react";
import type { MenuProps } from "antd";

export const Header: FC = () => {
    const navigate = useNavigate();
    const location = useLocation();
    const screens = useBreakpoint();
    const [visible, setVisible] = useState(false);

    const items: MenuProps["items"] = [
        {
            key: "/sport",
            label: "Sportarten",
            icon: <ListBullets />,
        },
        {
            key: "/syncConfig",
            label: "Meine Kalender",
            icon: <CalendarBlank />,
        }
    ];

    // Corrected function to match Ant Design's expected type
    const handleMenuClick: MenuProps["onClick"] = (info) => {
        navigate(info.key); // info.key is already the path
        setVisible(false); // Close drawer after selecting an item
    };

    const { token } = theme.useToken();

    return (
        <Layout.Header
            style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                padding: "0 24px",
                backgroundColor: "white",
                margin: "20px 20px 0px 20px",
                borderRadius: token.borderRadius,
            }}
        >
            <Flex style={{ flex: 1, justifyContent: "space-between", alignItems: "center" }}>
                {screens.md && (
                    <Image
                        src={"./assets/Logo_synci.png"}
                        preview={false}
                        style={{
                            cursor: "pointer",
                            padding: "10px 50px 10px 0px",
                            maxHeight: 50,
                        }}
                        onClick={() => {
                            navigate("/");
                        }}
                    />
                )}
                {screens.md ? (
                    <Menu
                        mode="horizontal"
                        items={items}
                        style={{ flex: 1, minWidth: 0, backgroundColor: "white" }}
                        onClick={handleMenuClick}
                        selectedKeys={[location.pathname]}
                    />
                ) : (
                    <>
                        <Button
                            type="text"
                            size="large"
                            onClick={() => setVisible(true)}
                            icon={<IconMenu2 size={24} />}
                        />
                        <Drawer title="Menü"
                                placement="left"
                                width={300}
                                onClose={() => setVisible(false)}
                                open={visible}
                                styles={{ body: { display: "flex", flexDirection: "column", padding: 0 } }}>
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
                                selectedKeys={[location.pathname]}
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
                                <Button
                                    type="primary"
                                    block
                                    icon={<Coffee size={18} weight="fill" />}
                                    style={{ height: 48, fontWeight: 600 }}
                                    onClick={() => {
                                        window.open("https://buymeacoffee.com/boostershack", "_blank");
                                    }}
                                >
                                    Team unterstützen
                                </Button>
                                <Typography.Text type="secondary" style={{ fontSize: 12 }}>
                                    Version {__APP_VERSION__} · © 2026 Synci
                                </Typography.Text>
                            </Flex>
                        </Drawer>
                    </>
                )}
            </Flex>
            <UserProfile />
        </Layout.Header>
    );
};
