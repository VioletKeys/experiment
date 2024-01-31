#[macro_use] extern crate rocket;

#[cfg(test)]
mod tests;
mod redirector;
use rocket::fairing::AdHoc;
use rocket::mtls::Certificate;

#[get("/")]
fn mutual(cert: Certificate<'_>) -> String {
    format!("Hello! Here's what we know: [{}] {}", cert.serial(), cert.subject())
}

#[get("/", rank = 2)]
fn hello() -> &'static str {
    "Hello, world!"
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .attach(AdHoc::on_request("Debug", |req, _| Box::pin(async move {
            req.headers().iter().for_each(|h| println!("{:?}:{:?}", h.name, h.value));
        })))
        .mount("/", routes![hello, mutual])
        .attach(redirector::Redirector { port: 3000 })
}
