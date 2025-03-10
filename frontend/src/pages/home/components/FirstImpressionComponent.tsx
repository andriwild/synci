import {Button, Flex, Image, Typography} from "antd";
import {IconPlayerPlayFilled} from "@tabler/icons-react";
import {useNavigate} from "react-router-dom";

export const FirstImpressionComponent = () => {
    const navigate = useNavigate();

    return (
        <Flex style={{justifyContent: 'center', alignItems: 'center'}} id={"home-header"} wrap>
            <Flex
                flex={"1 1 400px"}
                justify={"center"}
            >
                <Image
                    src={'./assets/synci_preview_straight_cut.png'}
                    preview={false}
                    style={{
                        padding: '10%',
                        flexBasis: "50%",
                        maxWidth: "600px",
                    }
                    }
                />
            </Flex>
            <Flex vertical
                  flex={"1 1 400px"}
                  gap={20}
                  style={{
                      justifyContent: 'center',
                      alignItems: 'start',
                      alignContent: 'center',
                      padding: '40px'
                  }}>
                <Typography.Title
                    level={1}
                    style={{width: '100%'}}>Deine Sportevents <br/>überblicken und synchronisieren</Typography.Title>

                <Typography.Text
                    style={{maxWidth: "600px"}}>
                    Hast du den Überblick über deine Sportevents verloren?<br/>
                    Willkommen bei Synci, der Plattform für Sportevents. Hier kannst du deine Sportevents gratis abonnieren und synchronisieren.
                     </Typography.Text>
                <Flex style={{gap: 20, paddingTop: "20px", width: '100%'}}
                      justify={"start"}
                >
                    <Button type={'primary'} size={"large"} icon={<IconPlayerPlayFilled size={20}/>}
                            onClick={() => {
                                navigate('/sport');
                            }
                            }
                    >
                        Gratis starten
                    </Button>

                </Flex>
            </Flex>
        </Flex>
    );
}