create table IF NOT EXISTS book
(
    name varchar(20),
    id   serial not null
        constraint book_pk
            primary key
);

alter table book
    owner to testadmin;

INSERT INTO public.book (name, id) VALUES ('시인은 저녁에 감성이 돋는다', 1);
INSERT INTO public.book (name, id) VALUES ('오늘은 이만 쉴께요', 2);
INSERT INTO public.book (name, id) VALUES ('사업왕 심길후', 3);