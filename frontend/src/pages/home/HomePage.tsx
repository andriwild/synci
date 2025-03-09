import {FC, useState} from 'react';
import {Button, Flex, Image, Steps, message, theme, Typography} from 'antd';
import './HomePage.css';
import {IconInfoCircle, IconPlayerPlayFilled} from '@tabler/icons-react';
import {useNavigate} from 'react-router-dom';
import {IconLaurelWreath} from '@tabler/icons-react';
import {sportApi} from '../../services/sport/sportApi.ts';
import Title from 'antd/es/typography/Title';
import Link from 'antd/es/typography/Link';
import useBreakpoint from 'antd/es/grid/hooks/useBreakpoint';

export const HomePage: FC = () => {
    const {token} = theme.useToken();
    const navigate = useNavigate();
    const screens = useBreakpoint();
    const sports = sportApi.useGetAllQuery();

    const steps = [
        {
            title: 'Sportkategorie auswählen',
            content: (
                <Flex vertical={!screens.md} style={{width: screens.md ? '100%' : '200px', gap: '20px', padding: '20px'}}>
                    <div style={{flex: 1, whiteSpace: 'normal', textAlign: 'start', alignContent: 'start'}}>
                        <Title level={5}>Sportkategorie auswählen</Title>
                        <div>
                            Wähle die Kategorien aus, von denen du die Einträge in deinem Kalender haben möchtest.
                        </div>
                    </div>
                    <div style={{flex: 1, whiteSpace: 'normal', marginRight: '5px', alignItems: 'center'}}>
                        <Image
                            src={'./public/assets/images/categories-screenshot.png'}
                            preview={false}
                            style={{height: 'auto'}}
                        />
                    </div>
                </Flex>
            ),
        },
        {
            title: 'Konfiguration hinzufügen',
            content: (
                <Flex style={{width: '100%', gap: '20px', padding: '10px'}}>
                    <div style={{flex: 1, whiteSpace: 'normal', textAlign: 'start', alignContent: 'start'}}>
                        <Title level={5}>Konfiguration hinzufügen</Title>
                        <div>
                            Egal welchen Kalender du verwendest. Wir fügen deine geliebten Sportevents direkt deinem
                            Kalender nach Wahl hinzu.
                        </div>
                    </div>
                    <div style={{flex: 1, whiteSpace: 'normal', marginRight: '5px', alignItems: 'center'}}>
                        <Image
                            src={'./public/assets/images/save-category-screenshot.png'}
                            preview={false}
                            style={{height: 'auto'}}
                        />
                    </div>
                </Flex>
            ),
        },
        {
            title: 'Synci unterstützen',
            content: (
                <Flex style={{width: '100%', gap: '20px', padding: '10px'}}>
                    <Flex vertical style={{flex: 1, textAlign: 'start', gap: 8}}>
                        <Title level={5} style={{marginBottom: 4}}>Synci unterstützen</Title>
                        <Typography.Text>
                            Wenn du willst, kannst du uns unterstützen. Das ist komplett freiwillig. Vielen Dank für
                            deine Unterstützung!
                            <br/>
                            Falls du kein Twint hast, kannst du uns hier unterstützen:
                        </Typography.Text>
                        <Link
                            onClick={() => window.open('https://buymeacoffee.com/boostershack', '_blank')}
                        >
                            Buy me a coffee
                        </Link>
                    </Flex>


                    <div style={{flex: 1, whiteSpace: 'normal', marginRight: '5px', alignItems: 'center'}}>
                        <Image
                            src={'./public/assets/images/support-synci-screenshot.png'}
                            preview={false}
                            style={{height: 'auto'}}
                        />
                    </div>
                </Flex>
            ),
        },
        {
            title: 'Einträge abgespeichert',
            content: (
                <Flex style={{width: '100%', gap: '20px', padding: '10px'}}>
                    <div style={{flex: 1, whiteSpace: 'normal', textAlign: 'start', alignContent: 'start'}}>
                        <Title level={5}>Einträge abgespeichert</Title>
                        <div>
                            Deine Events sind nun in deinem Kalender abgespeichert. Wenn du gewisse Einträge nicht mehr
                            abonnieren möchtest, kannst du dies hier wieder ändern.
                        </div>
                    </div>
                    <div style={{flex: 1, whiteSpace: 'normal', marginRight: '5px', alignItems: 'center'}}>
                        <Image
                            src={'./public/assets/images/category-entry-screenshot.png'}
                            preview={false}
                            style={{height: 'auto', maxHeight: '180px'}}
                        />
                    </div>
                </Flex>
            ),
        },
    ];

    const [current, setCurrent] = useState(0);

    const next = () => {
        setCurrent(current + 1);
    };

    const prev = () => {
        setCurrent(current - 1);
    };

    const items = steps.map((item) => ({key: item.title, title: item.title}));

    const contentStyle: React.CSSProperties = {
        height: '260px',
        alignContent: 'center',
        textAlign: 'center',
        color: token.colorTextBase,
        backgroundColor: 'white',
        borderRadius: token.borderRadiusLG,
        border: `1px ${token.colorBorder}`,
        marginTop: 42,
    };

    return (
        <Flex vertical style={{width: '100%'}} id={'home-container'}>
            <Flex style={{justifyContent: 'center', alignItems: 'center'}} id={'home-header'}>
                <Image
                    src={'./assets/synci_preview_straight_cut.png'}
                    preview={false}
                    style={{
                        padding: '10%',
                        flexBasis: '50%',
                    }
                    }
                />
                <Flex vertical style={{
                    justifyContent: 'center',
                    alignItems: 'start',
                    alignContent: 'center',
                    flexBasis: '50%',
                }}>
                    <Typography.Title
                        level={1}
                        style={{width: '80%'}}>Deine Sportevents <br/>überblicken und synchronisieren</Typography.Title>

                    <Typography.Text
                        style={{width: '80%'}}>
                        Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt
                        ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo
                        dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor
                        sit amet.
                    </Typography.Text>
                    <Flex style={{gap: 20, paddingTop: '20px'}}>
                        <Button type={'primary'} size={'large'} icon={<IconPlayerPlayFilled size={20}/>}
                                onClick={() => {
                                    navigate('/sport');
                                }
                                }
                        >
                            GRATIS starten
                        </Button>
                        <Button type={'default'} size={'large'}
                                icon={<IconInfoCircle size={20}/>}
                        >Mehr erfahren</Button>
                    </Flex>
                </Flex>
            </Flex>
            <Flex vertical style={{justifyContent: 'start', alignItems: 'center', margin: 'auto', padding: '60px 0'}}>
                <Typography.Title level={2} style={{marginBottom: 70}}>
                    Verfügbare Sportarten
                </Typography.Title>
                <Flex
                    gap={'middle'}
                    style={{
                        flexDirection: screens.md ? 'row' : 'column',
                        alignItems: 'center',
                    }}
                >
                    {sports.data?.map((sport) => (
                        <Flex
                            className="sport-card"
                            vertical
                            style={{
                                background: token.colorBgContainer,
                                alignItems: 'center',
                                width: '360px',
                            }}
                        >
                            <IconLaurelWreath size={50} style={{color: token.colorPrimary, marginTop: '20px'}}/>
                            <Typography.Title level={3}>{sport.name}</Typography.Title>
                        </Flex>
                    ))}
                </Flex>

                <Button
                    type={'primary'}
                    size={'large'}
                    style={{
                        marginTop: '60px',
                    }}
                    onClick={() => {
                        navigate('/sport');
                    }}
                >
                    Jetzt Kalender konfigurieren
                </Button>
            </Flex>
            <Flex vertical style={{
                justifyContent: 'start',
                alignItems: 'center',
                paddingTop: '60px',
                backgroundColor: token.colorBgBase,
                padding: '60px 0',
            }}>
                <Typography.Title level={2} style={{marginBottom: 70}}>
                    So einfach funktioniert Synci
                </Typography.Title>
                <Flex vertical style={{width: '800px'}}>
                    <Steps current={current} items={items} direction={screens.md ? 'horizontal' : 'vertical'}/>
                    <div style={contentStyle} id={steps[current].title}>{steps[current].content}</div>
                    <div style={{marginTop: 24, display: 'flex', justifyContent: 'flex-end'}}>
                        {current > 0 && (
                            <Button style={{margin: '0 8px'}} onClick={() => prev()}>
                                Vorheriger Schritt
                            </Button>
                        )}
                        {current < steps.length - 1 && (
                            <Button type="primary" onClick={() => next()}>
                                Nächster Schritt
                            </Button>
                        )}
                        {current === steps.length - 1 && (
                            <Button type="primary" onClick={() => message.success('Processing complete!')}>
                                Fertig
                            </Button>
                        )}
                    </div>
                </Flex>
            </Flex>
        </Flex>
    );
};
