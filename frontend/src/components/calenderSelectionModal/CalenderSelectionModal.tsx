import {Button, ButtonProps, Divider, Flex, Image, Modal, Typography} from "antd";
import {ReactNode, useState} from "react";
import "./CalenderSelectionModal.css";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";

interface CalendarSelectionProps {
    url: string;
    buttonType: ButtonProps["type"];
    buttonIcon: ReactNode;
    buttonText: string;
}

export const CalendarSelectionModal = ({url, buttonText, buttonType, buttonIcon}: CalendarSelectionProps) => {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const screen = useBreakpoint();

    return (
        <>
            <Button
                type={buttonType}
                icon={buttonIcon}
                onClick={() => setIsModalOpen(true)}
            >{buttonText}</Button>
            <Modal
                open={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                onCancel={() => setIsModalOpen(false)}
            >
                <Flex
                    flex={"1 1 1"}
                    justify={"center"}
                    align={"center"}
                    gap={20}
                    vertical
                >
                    <Typography.Title level={4}>Kalender hinzufügen</Typography.Title>
                    <Flex gap={10}>
                        <Button
                            type="primary"
                            onClick={() => {
                                window.open("webcal://" + url)
                            }
                            }
                        >Standard-Mailprogramm</Button>
                        <Button
                            type="primary"
                            onClick={() => {
                                window.open("https://calendar.google.com/calendar/u/0/r?cid=" + url + "&name=Sportevents-Synci")
                            }
                            }
                        >Google Calender einfügen</Button>
                        <Button
                            type="primary"
                            onClick={() => {
                                window.open("https://outlook.live.com/owa/?path=/calendar/action/compose&rru=addcalendar&url=" + url + "&name=Sportevents-Synci")
                            }
                            }
                        >In Outlook Live einfügen</Button>
                    </Flex>
                    <Divider/>

                    <Typography.Title level={4}>Synci unterstützen</Typography.Title>
                    <Flex gap={10} vertical
                          align={"center"}>
                        {screen.md ?
                            <Image
                                src={"./assets/twint/Synci_twint_code.png"}
                                preview={false}
                                style={{
                                    height: "auto",
                                }}
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
                        <Typography.Link>https://buymeacoffee.com/boostershack</Typography.Link>
                    </Flex>

                </Flex>
            </Modal>
        </>

    );
}