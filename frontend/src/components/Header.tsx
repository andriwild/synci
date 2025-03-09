import { FC, useState } from "react";
import {Button, Divider, Drawer, Flex, Image, Layout, Menu, theme, Typography} from "antd";
import { useLocation, useNavigate } from "react-router-dom";
import { CalendarBlank, ListBullets, QuestionMark } from "@phosphor-icons/react";
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
        },
        {
            key: "/faq",
            label: "Wie funktionierts",
            icon: <QuestionMark />,
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
                        <Drawer title="Menu"
                                placement="left"
                                width={"300px"}
                                onClose={() => setVisible(false)}
                                open={visible}>
                            <Menu
                                mode="vertical"
                                items={items}
                                style={{ flex: 1, minWidth: 0, backgroundColor: "transparent" }}
                                onClick={handleMenuClick}
                                selectedKeys={[location.pathname]}
                            />
                            <Divider style={{
                                borderColor: token.colorPrimary,
                                padding: "20px 0",
                            }} />
                            <Flex vertical={true} style={{ alignItems: "center", gap: 10 }}>

                            <Image
                                src={"./assets/Logo_synci.png"}
                                preview={false}
                                style={{
                                    cursor: "pointer",
                                    maxHeight: 60,
                                }}
                                onClick={() => {
                                    close();
                                    navigate("/");
                                }}
                            />
                            <Typography.Title level={4}>
                                Version 1.0
                            </Typography.Title>
                            <Typography.Title level={5}>
                                © 2021 Synci
                            </Typography.Title>
                                <Button
                                    type="default"
                                    style={{ width: "100%" }}
                                    onClick={() => {
                                        window.open("https://buymeacoffee.com/boostershack", "_blank");
                                    }}
                                >
                                    Synci unterstützen
                                </Button>
                            </Flex>
                        </Drawer>
                    </>
                )}
            </Flex>
            <UserProfile />
        </Layout.Header>
    );
};
