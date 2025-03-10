import {Button, Flex, Image, message, Steps, theme, Typography} from "antd";
import Title from "antd/es/typography/Title";
import Link from "antd/es/typography/Link";
import {useState} from "react";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";
import "./TutorialStepperComponent.css";

export const TutorialStepperComponent = () => {
    const [current, setCurrent] = useState(0);
    const screens = useBreakpoint();
    const {token} = theme.useToken();

    const steps = [
        {
            title: 'Sportkategorie auswählen',
            content: (
                <>
                    <div style={{flex: "1 1 300px", whiteSpace: 'normal', textAlign: 'start', alignContent: 'start'}}>
                        <Title level={5} className={"step-content-title"}>Sportkategorie auswählen</Title>
                        <div>
                            Wähle die Kategorien aus, von denen du die Einträge in deinem Kalender haben möchtest.
                        </div>
                    </div>
                    <div style={{flex: "1 1 300px", whiteSpace: 'normal', marginRight: '5px', alignItems: 'center'}}>
                        <Image
                            src={'./assets/images/categories-screenshot.png'}
                            preview={false}
                            style={{height: 'auto'}}
                        />
                    </div>
                </>
            ),
        },
        {
            title: 'Konfiguration hinzufügen',
            content: (
                <>
                    <div style={{flex: 1, whiteSpace: 'normal', textAlign: 'start', alignContent: 'start'}}>
                        <Title level={5}>Konfiguration hinzufügen</Title>
                        <div>
                            Egal welchen Kalender du verwendest. Wir fügen deine geliebten Sportevents direkt deinem
                            Kalender nach Wahl hinzu.
                        </div>
                    </div>
                    <div style={{flex: 1, whiteSpace: 'normal', marginRight: '5px', alignItems: 'center'}}>
                        <Image
                            src={'./assets/images/save-category-screenshot.png'}
                            preview={false}
                            style={{height: 'auto'}}
                        />
                    </div>
                </>
            ),
        },
        {
            title: 'Synci unterstützen',
            content: (
                <>
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
                            src={'./assets/images/support-synci-screenshot.png'}
                            preview={false}
                            style={{height: 'auto'}}
                        />
                    </div>
                </>
            ),
        },
        {
            title: 'Einträge abgespeichert',
            content: (
                <>
                    <div style={{flex: 1, whiteSpace: 'normal', textAlign: 'start', alignContent: 'start'}}>
                        <Title level={5}>Einträge abgespeichert</Title>
                        <div>
                            Deine Events sind nun in deinem Kalender abgespeichert. Wenn du gewisse Einträge nicht mehr
                            abonnieren möchtest, kannst du dies hier wieder ändern.
                        </div>
                    </div>
                    <div style={{flex: 1, whiteSpace: 'normal', marginRight: '5px', alignItems: 'center'}}>
                        <Image
                            src={'./assets/images/category-entry-screenshot.png'}
                            preview={false}
                            style={{height: 'auto', maxHeight: '180px'}}
                        />
                    </div>
                </>
            ),
        },
    ];

    const next = () => {
        setCurrent(current + 1);
    };

    const prev = () => {
        setCurrent(current - 1);
    };

    const items = steps.map((item) => ({key: item.title, title: item.title}));

    const contentStyle: React.CSSProperties = {
        alignContent: 'center',
        backgroundColor: 'white',
        gap: '20px',
        borderRadius: token.borderRadius,
        padding: '40px',
        marginTop: '40px',
    };
    return (

        <Flex vertical style={{
            justifyContent: 'start',
            alignItems: 'center',
            paddingTop: '60px',
            backgroundColor: token.colorBgBase,
            padding: '40px 0',
        }}>
            <Typography.Title level={2} style={{marginBottom: 70}}>
                So einfach funktioniert Synci
            </Typography.Title>
            <Flex vertical style={{width: "80%"}}>
                <Steps current={current} items={items} direction={screens.md ? 'horizontal' : 'vertical'}/>
                <Flex style={contentStyle} id={steps[current].title}>{steps[current].content}</Flex>
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
    );
}