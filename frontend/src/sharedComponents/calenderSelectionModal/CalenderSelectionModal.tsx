import {Button, ButtonProps, Divider, Flex, Image, Modal, Typography} from "antd";
import {ReactNode, useState} from "react";
import "./CalenderSelectionModal.css";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";
import {IconBrandGoogle, IconBrandOffice, IconCalendarPlus, IconMail} from "@tabler/icons-react";
import {useUser} from "../../services/user/UserSlice.ts";

interface CalendarSelectionProps {
    url: string;
    buttonType: ButtonProps["type"];
    buttonIcon: ReactNode;
    buttonText: string;
}

export const CalendarSelectionModal = ({url, buttonText, buttonType, buttonIcon}: CalendarSelectionProps) => {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const screen = useBreakpoint();
    const user = useUser();

    return (
        <>
            <Button
                type={buttonType}
                icon={buttonIcon}
                onClick={() => setIsModalOpen(true)}
                disabled={!user}
                title={user ? "" : "Melde dich an, um den Kalender hinzuzufügen"}
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
                    <Typography.Title level={4}>Kalender hinzufügen</Typography.Title>
                    <Flex gap={40}>
                        <Flex vertical gap={10} align={"center"}  flex={1} justify={"space-between"}>
                            <IconMail size={50}/>
                            <Typography.Title
                                style={{
                                    textAlign: "center",
                                    margin: 0
                            }}
                                level={5}>Standard Kalender</Typography.Title>
                            <Button
                                icon={<IconCalendarPlus size={20}/>}
                                disabled={!user}
                                type="primary"
                                onClick={() => {
                                    window.open("webcal://" + url)
                                }
                                }
                            >Einfügen</Button>
                        </Flex>
                        <Flex vertical gap={10} align={"center"} flex={1} justify={"space-between"}>
                            <IconBrandGoogle size={50}/>
                            <Typography.Title
                                style={{
                                    textAlign: "center",
                                    margin: 0
                                }}
                                level={5}>Google Kalender</Typography.Title>
                            <Button
                                icon={<IconCalendarPlus size={20}/>}
                                type="primary"
                                onClick={() => {
                                    window.open("https://calendar.google.com/calendar/u/0/r?cid=webcal://" + url)
                                }
                                }
                            >Einfügen</Button>
                        </Flex>
                        <Flex vertical gap={10} align={"center"}  flex={1} justify={"space-between"}>
                            <IconBrandOffice size={50}/>
                            <Typography.Title
                                style={{
                                    textAlign: "center",
                                    margin: 0
                                }}
                                level={5}>Outlook Live</Typography.Title>

                            <Button
                                icon={<IconCalendarPlus size={20}/>}
                                type="primary"
                                onClick={() => {


                                        window.open("https://outlook.live.com/calendar/0/addcalendar?source=fromUrl&url=https" + url + "&name=Sportevents-Synci")
                                }
                                }
                            >Einfügen</Button>
                        </Flex>
                    </Flex>
                    <Divider children={"Willst du uns unterstützen?"} />
                    <Flex gap={10} vertical
                          align={"center"}>
                        {screen.md ?
                            <Image
                                src={"./assets/twint/Synci_twint_code.png"}
                                preview={false}
                                width={400}
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