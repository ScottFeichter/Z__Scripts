#!/bin/bash

# Argument of the script that will be the root dir name

PROJECT_NAME=$1

# Create project directory and navigate into it
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME || return

# Initialize npm project
npm init -y

# Create directory structure
mkdir -p public/images
mkdir -p src/components
mkdir -p src/styles
mkdir -p src/utils

# Create public files
touch public/index.html
touch public/favicon.ico

# Create source files
touch src/App.js
touch src/index.js
touch src/index.css

# Create component files
touch src/components/Home.js
touch src/components/Services.js
touch src/components/Contact.js
touch src/components/Portfolio.js
touch src/components/Testimonials.js
touch src/components/Team.js
touch src/components/Navbar.js
touch src/components/Footer.js

# Create style files
touch src/styles/services.css
touch src/styles/contact.css
touch src/styles/portfolio.css
touch src/styles/testimonials.css
touch src/styles/team.css
touch src/styles/footer.css
touch src/styles/responsive.css

# Create utils file
touch src/utils/validation.js

# Create root files
touch README.md
touch .gitignore

# Populate src/index.js
cat > src/index.js << 'EOL'
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOL

# Populate public/index.html
cat > public/index.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta
      name="description"
      content="Business solutions for cloud migration, custom applications, and A/V solutions"
    />
    <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
    <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
    <title>Business Solutions</title>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOL

# Populate src/index.css
cat > src/index.css << 'EOL'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* Navbar Styles */
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  background-color: white;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.nav-links {
  display: flex;
  gap: 2rem;
}

.nav-links a {
  text-decoration: none;
  color: #333;
  font-weight: 500;
}

/* Hero Section Styles */
.hero {
  background: linear-gradient(rgba(0,0,0,0.7), rgba(0,0,0,0.7));
  height: 80vh;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  text-align: center;
}

.hero-content {
  max-width: 800px;
  padding: 2rem;
}

.hero h1 {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.cta-button {
  background: #007bff;
  color: white;
  border: none;
  padding: 1rem 2rem;
  border-radius: 5px;
  font-size: 1.1rem;
  cursor: pointer;
  margin-top: 2rem;
}

/* Services Preview Styles */
.services-preview {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  padding: 4rem 2rem;
}

.service-card {
  background: white;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
EOL


# Populate App.js
cat > src/App.js << 'EOL'
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './components/Home';
import Services from './components/Services';
import Contact from './components/Contact';
import Portfolio from './components/Portfolio';
import Team from './components/Team';
import Navbar from './components/Navbar';
import Footer from './components/Footer';

function App() {
  return (
    <Router>
      <div className="App">
        <Navbar />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/services" element={<Services />} />
          <Route path="/contact" element={<Contact />} />
          <Route path="/portfolio" element={<Portfolio />} />
          <Route path="/team" element={<Team />} />
        </Routes>
        <Footer />
      </div>
    </Router>
  );
}

export default App;
EOL

# Populate Home.js
cat > src/components/Home.js << 'EOL'
import React from 'react';

function Home() {
  return (
    <div className="home">
      <section className="hero">
        <div className="hero-content">
          <h1>Transform Your Business with Cloud Solutions</h1>
          <p>Expert cloud migration, custom applications, and A/V solutions</p>
          <button className="cta-button">Get Started</button>
        </div>
      </section>

      <section className="services-preview">
        <div className="service-card">
          <h3>Cloud Migration</h3>
          <p>Seamless transition to cloud infrastructure with minimal downtime</p>
        </div>
        <div className="service-card">
          <h3>Custom Applications</h3>
          <p>Tailored software solutions to meet your specific business needs</p>
        </div>
        <div className="service-card">
          <h3>A/V Solutions</h3>
          <p>State-of-the-art audio/visual systems for modern workspaces</p>
        </div>
      </section>
    </div>
  );
}

export default Home;
EOL

# Populate Portfolio.js
cat > src/components/Portfolio.js << 'EOL'
import React from 'react';

function Portfolio() {
  const caseStudies = [
    {
      id: 1,
      title: "Enterprise Cloud Migration",
      client: "Global Manufacturing Corp",
      description: "Successfully migrated legacy systems to AWS, resulting in 40% cost reduction",
      image: "/images/case-study-1.jpg",
      results: [
        "99.99% uptime achieved",
        "Reduced operational costs by 40%",
        "Improved system performance by 60%"
      ]
    }
  ];

  return (
    <div className="portfolio-page">
      <header className="portfolio-header">
        <h1>Success Stories</h1>
        <p>Real results for real businesses</p>
      </header>

      <div className="case-studies-grid">
        {caseStudies.map(study => (
          <div key={study.id} className="case-study-card">
            <div className="case-study-image">
              <img src={study.image} alt={study.title} loading="lazy" />
            </div>
            <div className="case-study-content">
              <h3>{study.title}</h3>
              <h4>{study.client}</h4>
              <p>{study.description}</p>
              <div className="results">
                <h5>Key Results:</h5>
                <ul>
                  {study.results.map((result, index) => (
                    <li key={index}>{result}</li>
                  ))}
                </ul>
              </div>
              <button className="read-more-btn">Read Full Case Study</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default Portfolio;
EOL

# Populate Services.js
cat > src/components/Services.js << 'EOL'
import React from 'react';

function Services() {
  const services = [
    {
      id: 1,
      title: "Cloud Migration",
      description: "Seamless transition to cloud infrastructure with comprehensive planning and execution.",
      features: [
        "AWS/Azure/GCP migration expertise",
        "Zero-downtime migration strategies",
        "Legacy system modernization",
        "Post-migration support and optimization"
      ],
      icon: "🚀"
    },
    {
      id: 2,
      title: "Custom Applications",
      description: "Bespoke software solutions tailored to your business requirements.",
      features: [
        "Full-stack development",
        "Mobile applications",
        "Enterprise software",
        "API integration"
      ],
      icon: "💻"
    },
    {
      id: 3,
      title: "Audio/Visual Solutions",
      description: "State-of-the-art A/V systems for modern business environments.",
      features: [
        "Conference room setup",
        "Digital signage",
        "Video conferencing systems",
        "Sound system installation"
      ],
      icon: "🎥"
    }
  ];

  return (
    <div className="services-page">
      <header className="services-header">
        <h1>Our Services</h1>
        <p>Comprehensive solutions for your business needs</p>
      </header>

      <div className="services-grid">
        {services.map(service => (
          <div key={service.id} className="service-detail-card">
            <div className="service-icon">{service.icon}</div>
            <h2>{service.title}</h2>
            <p>{service.description}</p>
            <ul className="features-list">
              {service.features.map((feature, index) => (
                <li key={index}>{feature}</li>
              ))}
            </ul>
            <button className="learn-more-btn">Learn More</button>
          </div>
        ))}
      </div>
    </div>
  );
}

export default Services;
EOL

# Populate Contact.js
cat > src/components/Contact.js << 'EOL'
import React, { useState } from 'react';

function Contact() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    company: '',
    message: ''
  });
  const [errors, setErrors] = useState({});
  const [submitStatus, setSubmitStatus] = useState('');

  const validateForm = () => {
    let tempErrors = {};
    if (!formData.name) tempErrors.name = 'Name is required';
    if (!formData.email) {
      tempErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      tempErrors.email = 'Email is invalid';
    }
    if (!formData.message) tempErrors.message = 'Message is required';
    setErrors(tempErrors);
    return Object.keys(tempErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (validateForm()) {
      setSubmitStatus('sending');
      try {
        await new Promise(resolve => setTimeout(resolve, 1000));
        setSubmitStatus('success');
        setFormData({ name: '', email: '', company: '', message: '' });
      } catch (error) {
        setSubmitStatus('error');
      }
    }
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  return (
    <div className="contact-page">
      <div className="contact-container">
        <div className="contact-info">
          <h1>Get in Touch</h1>
          <p>Ready to transform your business? Contact us today.</p>
          <div className="contact-details">
            <div className="contact-item">
              <i className="fas fa-map-marker-alt"></i>
              <p>123 Business Street, Suite 100<br />City, State 12345</p>
            </div>
            <div className="contact-item">
              <i className="fas fa-phone"></i>
              <p>+1 (555) 123-4567</p>
            </div>
            <div className="contact-item">
              <i className="fas fa-envelope"></i>
              <p>contact@yourcompany.com</p>
            </div>
          </div>
        </div>

        <form className="contact-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="name">Name *</label>
            <input
              type="text"
              id="name"
              name="name"
              value={formData.name}
              onChange={handleChange}
              className={errors.name ? 'error' : ''}
            />
            {errors.name && <span className="error-message">{errors.name}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="email">Email *</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              className={errors.email ? 'error' : ''}
            />
            {errors.email && <span className="error-message">{errors.email}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="company">Company</label>
            <input
              type="text"
              id="company"
              name="company"
              value={formData.company}
              onChange={handleChange}
            />
          </div>

          <div className="form-group">
            <label htmlFor="message">Message *</label>
            <textarea
              id="message"
              name="message"
              value={formData.message}
              onChange={handleChange}
              className={errors.message ? 'error' : ''}
            />
            {errors.message && <span className="error-message">{errors.message}</span>}
          </div>

          <button
            type="submit"
            className="submit-btn"
            disabled={submitStatus === 'sending'}
          >
            {submitStatus === 'sending' ? 'Sending...' : 'Send Message'}
          </button>

          {submitStatus === 'success' && (
            <div className="success-message">Message sent successfully!</div>
          )}
          {submitStatus === 'error' && (
            <div className="error-message">Failed to send message. Please try again.</div>
          )}
        </form>
      </div>
    </div>
  );
}

export default Contact;
EOL

# Populate Team.js
cat > src/components/Team.js << 'EOL'
import React from 'react';

function Team() {
  const team = [
    {
      id: 1,
      name: "Sarah Johnson",
      position: "Cloud Solutions Architect",
      bio: "15+ years experience in enterprise cloud migrations",
      image: "/images/team-1.jpg",
      social: {
        linkedin: "https://linkedin.com/in/sarahjohnson",
        twitter: "https://twitter.com/sarahjohnson"
      }
    }
  ];

  return (
    <section className="team-section">
      <h2>Our Expert Team</h2>
      <p>Meet the professionals behind our success</p>

      <div className="team-grid">
        {team.map(member => (
          <div key={member.id} className="team-member-card">
            <div className="member-image">
              <img src={member.image} alt={member.name} loading="lazy" />
            </div>
            <div className="member-info">
              <h3>{member.name}</h3>
              <h4>{member.position}</h4>
              <p>{member.bio}</p>
              <div className="social-links">
                {member.social.linkedin && (
                  <a href={member.social.linkedin} target="_blank" rel="noopener noreferrer">
                    <i className="fab fa-linkedin"></i>
                  </a>
                )}
                {member.social.twitter && (
                  <a href={member.social.twitter} target="_blank" rel="noopener noreferrer">
                    <i className="fab fa-twitter"></i>
                  </a>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}

export default Team;
EOL

# Populate Footer.js
cat > src/components/Footer.js << 'EOL'
import React from 'react';
import { Link } from 'react-router-dom';

function Footer() {
  return (
    <footer className="footer">
      <div className="footer-content">
        <div className="footer-section">
          <h3>About Us</h3>
          <p>Leading provider of cloud migration, custom applications, and A/V solutions for businesses.</p>
        </div>

        <div className="footer-section">
          <h3>Quick Links</h3>
          <ul>
            <li><Link to="/">Home</Link></li>
            <li><Link to="/services">Services</Link></li>
            <li><Link to="/portfolio">Portfolio</Link></li>
            <li><Link to="/contact">Contact</Link></li>
          </ul>
        </div>

        <div className="footer-section">
          <h3>Contact Info</h3>
          <p>123 Business Street, Suite 100</p>
          <p>City, State 12345</p>
          <p>Phone: (555) 123-4567</p>
          <p>Email: contact@yourcompany.com</p>
        </div>

        <div className="footer-section">
          <h3>Follow Us</h3>
          <div className="social-links">
            <a href="#" target="_blank" rel="noopener noreferrer"><i className="fab fa-linkedin"></i></a>
            <a href="#" target="_blank" rel="noopener noreferrer"><i className="fab fa-twitter"></i></a>
            <a href="#" target="_blank" rel="noopener noreferrer"><i className="fab fa-facebook"></i></a>
          </div>
        </div>
      </div>

      <div className="footer-bottom">
        <p>&copy; {new Date().getFullYear()} Your Company Name. All rights reserved.</p>
      </div>
    </footer>
  );
}

export default Footer;
EOL

# Populate Navbar.js
cat > src/components/Navbar.js << 'EOL'
import React from 'react';
import { Link } from 'react-router-dom';

function Navbar() {
  return (
    <nav className="navbar">
      <div className="logo">
        <Link to="/">YourCompany</Link>
      </div>
      <div className="nav-links">
        <Link to="/">Home</Link>
        <Link to="/services">Services</Link>
        <Link to="/contact">Contact</Link>
      </div>
    </nav>
  );
}

export default Navbar;
EOL

# Create .gitignore
cat > .gitignore << 'EOL'
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# production
/build

# misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOL

# Update package.json with dependencies
cat > package.json << 'EOL'
{
  "name": "$PROJECT_NAME",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@fortawesome/fontawesome-svg-core": "^6.4.0",
    "@fortawesome/free-brands-svg-icons": "^6.4.0",
    "@fortawesome/free-solid-svg-icons": "^6.4.0",
    "@fortawesome/react-fontawesome": "^0.2.0",
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^13.5.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.11.2",
    "react-scripts": "5.0.1",
    "web-vitals": "^2.1.4"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOL

# Install dependencies
echo "Installing dependencies..."
npm install


# Initializing git repository
echo "Initializing git local and remote..."

git init
touch README.md
git add .
git commit -m "initial (msg via shell)"

gh repo create $PROJECT_NAME --public

git remote add origin https://github.com/ScottFeichter/$PROJECT_NAME.git
git branch -M main
git push -u origin main


echo "Project setup complete! 🚀"
echo "Run 'npm start' to launch the development server."
