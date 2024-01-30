#[macro_use] extern crate rocket;

use rocket::fairing::AdHoc;

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .attach(AdHoc::on_request("Debug", |req, _| Box::pin(async move {
            req.headers().iter().for_each(|h| println!("{:?}:{:?}", h.name, h.value));
        })))
        .mount("/", routes![index])
}
