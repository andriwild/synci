import {Button, ButtonProps, Collapse, Flex, Modal, Typography} from "antd";
import {ReactNode, useState} from "react";
import "./CalenderSelectionModal.css";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";
import {IconBrandApple, IconBrandGoogle, IconBrandOffice} from "@tabler/icons-react";
import {useUser} from "../../services/user/UserSlice.ts";
import {useDeviceType} from "../../utils/useDeviceType.ts";
import {CalendarProvider, track} from "../../utils/analytics.ts";

interface CalendarSelectionProps {
    url: string;
    buttonType: ButtonProps["type"];
    buttonIcon: ReactNode;
    buttonText: string;
}

interface CalendarOption {
    key: CalendarProvider;
    label: string;
    icon: ReactNode;
    open: (url: string) => void;
}

const CALENDAR_OPTIONS: Record<"apple" | "google" | "outlook", CalendarOption> = {
    apple: {
        key: "apple",
        label: "Apple Kalender",
        icon: <IconBrandApple size={44}/>,
        open: (url) => window.open("https://" + url),
    },
    google: {
        key: "google",
        label: "Google Kalender",
        icon: <IconBrandGoogle size={44}/>,
        open: (url) => window.open("https://calendar.google.com/calendar/r?cid=" + encodeURIComponent("webcal://" + url)),
    },
    outlook: {
        key: "outlook",
        label: "Outlook Live",
        icon: <IconBrandOffice size={44}/>,
        open: (url) => window.open("https://outlook.live.com/calendar/0/addcalendar?source=fromUrl&url=https" + url + "&name=Sportevents-Synci"),
    },
};

export const CalendarSelectionModal = ({url, buttonText, buttonType, buttonIcon}: CalendarSelectionProps) => {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const screen = useBreakpoint();
    const user = useUser();
    const deviceType = useDeviceType();

    const openCalendar = (option: CalendarOption) => {
        track("calendar-add", {provider: option.key});
        option.open(url);
    };

    const renderOptionColumn = (option: CalendarOption) => (
        <Flex key={option.key} vertical gap={12} align={"center"} flex={1} justify={"space-between"}>
            {option.icon}
            <Typography.Text strong style={{textAlign: "center"}}>{option.label}</Typography.Text>
            <Button
                disabled={!user}
                type="primary"
                onClick={() => openCalendar(option)}
            >Hinzufügen</Button>
        </Flex>
    );

    const renderSecondaryOption = (option: CalendarOption) => (
        <Button
            key={option.key}
            block
            size={"large"}
            disabled={!user}
            onClick={() => openCalendar(option)}
        >{option.label}</Button>
    );

    const copyLinkButton = (
        <Button block size={"large"} disabled={!user} onClick={() => {
            track("calendar-add", {provider: "copy"});
            navigator.clipboard.writeText("https://" + url);
        }}>
            Link manuell kopieren
        </Button>
    );

    const renderMoreOptions = (children: ReactNode) => (
        <Collapse
            ghost
            style={{width: "100%"}}
            items={[{
                key: "more",
                label: "Weitere Optionen",
                children: <Flex vertical gap={10}>{children}</Flex>,
            }]}
        />
    );

    const renderOptions = () => {
        if (screen.md && deviceType === "desktop") {
            return (
                <Flex vertical gap={24} align={"center"} style={{width: "100%"}}>
                    <Flex gap={32} wrap={"wrap"} justify={"center"} style={{width: "100%"}}>
                        {renderOptionColumn(CALENDAR_OPTIONS.apple)}
                        {renderOptionColumn(CALENDAR_OPTIONS.google)}
                        {renderOptionColumn(CALENDAR_OPTIONS.outlook)}
                    </Flex>
                    {renderMoreOptions(copyLinkButton)}
                </Flex>
            );
        }

        const primary = deviceType === "android" ? CALENDAR_OPTIONS.google : CALENDAR_OPTIONS.apple;
        const others = Object.values(CALENDAR_OPTIONS).filter((option) => option.key !== primary.key);

        return (
            <Flex vertical gap={16} align={"center"} style={{width: "100%"}}>
                <Flex vertical gap={8} align={"center"}>
                    {primary.icon}
                    <Typography.Text strong>{primary.label}</Typography.Text>
                </Flex>
                <Button
                    disabled={!user}
                    type="primary"
                    size={"large"}
                    block
                    style={{height: 52}}
                    onClick={() => openCalendar(primary)}
                >Hinzufügen</Button>
                {renderMoreOptions(
                    <>
                        {others.map(renderSecondaryOption)}
                        {copyLinkButton}
                    </>
                )}
            </Flex>
        );
    };

    return (
        <>
            <Button
                type={buttonType}
                icon={buttonIcon}
                onClick={() => {
                    track("calendar-modal-open");
                    setIsModalOpen(true);
                }}
                disabled={!user}
                title={user ? "" : "Melde dich an, um Kalender hinzuzufügen"}
            >{buttonText}</Button>
            <Modal
                open={isModalOpen}
                onCancel={() => setIsModalOpen(false)}
                title={"Kalender hinzufügen"}
                footer={null}
                width={screen.md ? "50%" : "90%"}
            >
                <Flex
                    align={"center"}
                    gap={24}
                    vertical
                    style={{paddingTop: 8}}
                >
                    {renderOptions()}
                </Flex>
            </Modal>
        </>

    );
}
