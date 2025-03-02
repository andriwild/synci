import {Button, Divider, Flex, Image, Popover, theme, Typography} from "antd";
import Title from "antd/es/typography/Title";
import {FC} from "react";
import {CalendarBlank, Placeholder, UserCircle} from "@phosphor-icons/react";

export const UserProfile: FC = () => {
    const {token} = theme.useToken();

    return (
        <Popover
            placement="bottomRight"
            trigger={"hover"}
            showArrow={false}
            overlayInnerStyle={{
                borderRadius: token.borderRadius,
                padding: '20px',
                width: '300px',
            }}
            content={
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
                            <Title level={5} style={{margin: 0}} color={token.colorPrimary}>Elias Bräm</Title>
                        </Flex>
                    </Flex>
                    <Divider
                        variant={"solid"}
                        style={{borderColor: token.colorPrimary}}
                    >
                        <Typography.Title level={5} style={{margin: 0, fontSize:'0.8rem'}}>Einstellungen</Typography.Title>
                    </Divider>
                    <Button icon={<CalendarBlank/>} type={'text'} style={{textAlign: 'start'}}>
                        Meine Kalender
                    </Button>
                    <Button icon={<UserCircle/>} type={'text'} style={{textAlign: 'start'}}>
                        Profil bearbeiten
                    </Button>
                    <Button
                        type={'default'}
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
                            onClick={() => {
                                //TODO: Implement logout
                            }}
                        >
                            Abmelden
                        </Button>

                </Flex>
            }
        >
            <Flex style={{alignItems: 'center', cursor: 'pointer', gap: 10}}>
                <Flex style={{flexDirection: 'column', alignItems: 'flex-end'}}>
                    <Typography.Text type={'secondary'} style={{margin: 0}}>Mein Konto</Typography.Text>
                    <Title level={5} style={{margin: 0}} color={token.colorPrimary}>Elias Bräm</Title>
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
            </Flex>
        </Popover>
    );
}
