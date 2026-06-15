import {Button, ButtonProps, Collapse, Divider, Flex, Image, Modal, Typography} from "antd";
import {ReactNode, useState} from "react";
import "./CalenderSelectionModal.css";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";
import {IconBrandApple, IconBrandGoogle, IconBrandOffice, IconCalendarPlus} from "@tabler/icons-react";
import {useUser} from "../../services/user/UserSlice.ts";
import {useDeviceType} from "../../utils/useDeviceType.ts";

interface CalendarSelectionProps {
    url: string;
    buttonType: ButtonProps["type"];
    buttonIcon: ReactNode;
    buttonText: string;
}

interface CalendarOption {
    key: string;
    label: string;
    icon: ReactNode;
    open: (url: string) => void;
}

const CALENDAR_OPTIONS: Record<"apple" | "google" | "outlook", CalendarOption> = {
    apple: {
        key: "apple",
        label: "Apple Kalender",
        icon: <IconBrandApple size={50}/>,
        open: (url) => window.open("webcal://" + url),
    },
    google: {
        key: "google",
        label: "Google Kalender",
        icon: <IconBrandGoogle size={50}/>,
        open: (url) => window.open("https://calendar.google.com/calendar/r?cid=" + encodeURIComponent("webcal://" + url)),
    },
    outlook: {
        key: "outlook",
        label: "Outlook Live",
        icon: <IconBrandOffice size={50}/>,
        open: (url) => window.open("https://outlook.live.com/calendar/0/addcalendar?source=fromUrl&url=https" + url + "&name=Sportevents-Synci"),
    },
};

export const CalendarSelectionModal = ({url, buttonText, buttonType, buttonIcon}: CalendarSelectionProps) => {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const screen = useBreakpoint();
    const user = useUser();
    const deviceType = useDeviceType();

    const renderOptionColumn = (option: CalendarOption) => (
        <Flex key={option.key} vertical gap={10} align={"center"} flex={1} justify={"space-between"}>
            {option.icon}
            <Typography.Title style={{textAlign: "center", margin: 0}} level={5}>{option.label}</Typography.Title>
            <Button
                icon={<IconCalendarPlus size={20}/>}
                disabled={!user}
                type="primary"
                onClick={() => option.open(url)}
            >Einfügen</Button>
        </Flex>
    );

    const renderSecondaryOption = (option: CalendarOption) => (
        <Button
            key={option.key}
            block
            size={"large"}
            disabled={!user}
            onClick={() => option.open(url)}
        >{option.label}</Button>
    );

    const renderOptions = () => {
        if (screen.md && deviceType === "desktop") {
            return (
                <Flex gap={40} wrap={"wrap"} justify={"center"} style={{width: "100%"}}>
                    {renderOptionColumn(CALENDAR_OPTIONS.apple)}
                    {renderOptionColumn(CALENDAR_OPTIONS.google)}
                    {renderOptionColumn(CALENDAR_OPTIONS.outlook)}
                </Flex>
            );
        }

        const primary = deviceType === "android" ? CALENDAR_OPTIONS.google : CALENDAR_OPTIONS.apple;
        const others = Object.values(CALENDAR_OPTIONS).filter((option) => option.key !== primary.key);

        return (
            <Flex vertical gap={16} align={"center"} style={{width: "100%"}}>
                <Button
                    icon={<IconCalendarPlus size={22}/>}
                    disabled={!user}
                    type="primary"
                    size={"large"}
                    block
                    style={{height: 56, fontSize: 18}}
                    onClick={() => primary.open(url)}
                >Zu {primary.label} hinzufügen</Button>
                <Collapse
                    ghost
                    style={{width: "100%"}}
                    items={[{
                        key: "more",
                        label: "Weitere Optionen",
                        children: (
                            <Flex vertical gap={10}>
                                {others.map(renderSecondaryOption)}
                            </Flex>
                        ),
                    }]}
                />
            </Flex>
        );
    };

    return (
        <>
            <Button
                type={buttonType}
                icon={buttonIcon}
                onClick={() => setIsModalOpen(true)}
                disabled={!user}
                title={user ? "" : "Melde dich an, um Kalender hinzuzufügen"}
            >{buttonText}</Button>
            <Modal
                open={isModalOpen}
                onCancel={() => setIsModalOpen(false)}
                width={screen.md ? "50%" : "90%"}
            >
                <Flex
                    align={"center"}
                    gap={20}
                    vertical
                >
                    <Typography.Title level={4}>Abo zu Kalender hinzufügen</Typography.Title>
                    {renderOptions()}
                    <Button onClick={() => navigator.clipboard.writeText("https://" + url)}>Abo Link in die Zwischenablage kopieren</Button>
                    <Divider children={"Willst du uns unterstützen?"} />
                    <Flex gap={10} vertical
                          align={"center"}>
                        {screen.md ?
                            <Image
                                src={"./assets/twint/Synci_twint_code.png"}
                                preview={false}
                                width={"100%"}
                                style={{maxWidth: 400}}
                            />
                            :
                            <Button
                                onClick={() => {
                                    window.open("https://go.twint.ch/1/e/tw?tw=acq.X02uCbRoQrmFpKiqJPEblOh-AIeo9bKVcSjWppoaVe4IFq8CAUymVV_UWtgY8DjH")
                                }
                                }>Twint
                            </Button>
                        }
                        <Typography.Text>Falls du kein Twint hast, kannst du uns hier unterstützen:</Typography.Text>
                        <Typography.Link
                            onClick={() => {
                                window.open("https://buymeacoffee.com/boostershack")
                            }
                            }
                            >https://buymeacoffee.com/boostershack</Typography.Link>
                    </Flex>

                </Flex>
            </Modal>
        </>

    );
}
