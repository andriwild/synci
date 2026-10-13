import {Button, Steps, theme, Typography} from "antd";
import Title from "antd/es/typography/Title";
import Link from "antd/es/typography/Link";
import {ReactNode, useState} from "react";
import {Link as RouterLink} from "react-router-dom";
import {useResponsive} from "../../../utils/useResponsive.ts";

/** text on the left, screenshot on the right; stacks on narrow screens */
const StepContent = ({title, children, image, imageAlt, maxHeight}: { title: string, children: ReactNode, image: string, imageAlt: string, maxHeight?: number }) => (
    <>
        <div style={{textAlign: "start"}}>
            <Title level={3} className={"step-content-title"}>{title}</Title>
            <div style={{marginTop: 8}}>{children}</div>
        </div>
        <div className="tutorial__image">
            <img src={image} alt={imageAlt} loading="lazy" style={maxHeight ? {maxHeight} : undefined}/>
        </div>
    </>
);

export const TutorialStepperComponent = () => {
    const [current, setCurrent] = useState(0);
    const {isMobile, isXs} = useResponsive();
    const {token} = theme.useToken();

    const steps = [
        {
            title: "Sportkategorie auswählen",
            content: (
                <StepContent title="Sportkategorie auswählen" image="/assets/images/categories-screenshot.png"
                             imageAlt="Screenshot der Sportarten-Auswahl in Synci">
                    Wähle die Kategorien aus, von denen du die Einträge in deinem Kalender haben möchtest.
                </StepContent>
            ),
        },
        {
            title: "Konfiguration hinzufügen",
            content: (
                <StepContent title="Konfiguration hinzufügen" image="/assets/images/save-category-screenshot.png"
                             imageAlt="Screenshot: Sportart zum Kalender-Abo hinzufügen">
                    Egal welchen Kalender du verwendest. Wir fügen deine geliebten Sportevents direkt deinem
                    Kalender nach Wahl hinzu.
                </StepContent>
            ),
        },
        {
            title: "Synci unterstützen",
            content: (
                <StepContent title="Synci unterstützen" image="/assets/images/support-synci-screenshot.png"
                             imageAlt="Screenshot des Unterstützen-Dialogs mit Twint">
                    <Typography.Text>
                        Wenn du willst, kannst du uns unterstützen. Das ist komplett freiwillig. Vielen Dank für
                        deine Unterstützung!
                        <br/>
                        Falls du kein Twint hast, kannst du uns hier unterstützen:
                    </Typography.Text>
                    <br/>
                    <Link href="https://buymeacoffee.com/boostershack" target="_blank" rel="noopener noreferrer">
                        Buy me a coffee
                    </Link>
                </StepContent>
            ),
        },
        {
            title: "Einträge abgespeichert",
            content: (
                <StepContent title="Einträge abgespeichert" image="/assets/images/category-entry-screenshot.png" maxHeight={180}
                             imageAlt="Screenshot eines abonnierten Eintrags im Kalender-Abo">
                    Deine Events sind nun in deinem Kalender abgespeichert. Wenn du gewisse Einträge nicht mehr
                    abonnieren möchtest, kannst du dies hier wieder ändern.
                </StepContent>
            ),
        },
    ];

    const items = steps.map((item) => ({key: item.title, title: item.title}));

    return (
        <div className="tutorial">
            <Typography.Title level={2} className="section-title">
                So einfach funktioniert Synci
            </Typography.Title>
            <div className="tutorial__inner">
                <Steps
                    current={current}
                    items={items}
                    progressDot={isXs}
                    size={isMobile ? "small" : "default"}
                    responsive={false}
                    onChange={setCurrent}
                />
                <div className="tutorial__content" style={{borderRadius: token.borderRadius}} id={steps[current].title}>
                    {steps[current].content}
                </div>
                <div className="tutorial__actions">
                    {current > 0 && (
                        <Button onClick={() => setCurrent(current - 1)}>
                            Vorheriger Schritt
                        </Button>
                    )}
                    {current < steps.length - 1 && (
                        <Button type="primary" onClick={() => setCurrent(current + 1)}>
                            Nächster Schritt
                        </Button>
                    )}
                    {current === steps.length - 1 && (
                        <RouterLink to="/sport">
                            <Button type="primary">Jetzt starten</Button>
                        </RouterLink>
                    )}
                </div>
            </div>
        </div>
    );
}
